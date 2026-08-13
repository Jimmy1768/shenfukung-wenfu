# frozen_string_literal: true

require "test_helper"

module Payments
  class CheckoutServiceTest < ActiveSupport::TestCase
    FakeTemple = Struct.new(:id)
    FakeRegistration = Struct.new(:temple, :user)
    FakePayment = Struct.new(:status, :provider_reference, :metadata, :temple_registration, keyword_init: true)

    class FakeAdapter
      attr_reader :checkout_calls

      def initialize(status:)
        @status = status
        @checkout_calls = 0
      end

      def checkout(intent:, amount_cents:, currency:, metadata:, idempotency_key:)
        @checkout_calls += 1
        {
          status: @status,
          provider_reference: "pay_ref_123",
          raw: {
            intent: intent,
            amount_cents: amount_cents,
            currency: currency,
            metadata: metadata,
            idempotency_key: idempotency_key
          }
        }
      end
    end

    class FakeResolver
      attr_reader :resolved_provider, :resolved_kwargs, :resolve_calls

      def initialize(adapter)
        @adapter = adapter
        @resolve_calls = 0
      end

      def resolve(provider:, **kwargs)
        @resolve_calls += 1
        @resolved_provider = provider
        @resolved_kwargs = kwargs
        @adapter
      end
    end

    class FakeRepository
      attr_reader :completed_intent_lookup, :created_attrs, :applied_status,
        :idempotency_lookups, :completed_intent_lookups, :create_calls, :apply_calls

      def initialize(existing_by_idempotency: nil, completed_for_intent: nil, created_payment: nil)
        @existing_by_idempotency = existing_by_idempotency
        @completed_for_intent = completed_for_intent
        @created_payment = created_payment || FakePayment.new(status: TemplePayment::STATUSES[:pending], metadata: {})
        @idempotency_lookups = 0
        @completed_intent_lookups = 0
        @create_calls = 0
        @apply_calls = 0
      end

      def find_by_idempotency(**)
        @idempotency_lookups += 1
        @existing_by_idempotency
      end

      def find_completed_by_intent(temple:, intent_key:)
        @completed_intent_lookups += 1
        @completed_intent_lookup = [temple, intent_key]
        @completed_for_intent
      end

      def create_pending!(**attrs)
        @create_calls += 1
        @created_attrs = attrs
        @created_payment
      end

      def apply_checkout_result!(payment:, status:, provider_reference:, payload:, metadata:)
        @apply_calls += 1
        @applied_status = status
        payment.status = status
        payment.provider_reference = provider_reference
        payment.metadata = metadata
        payment
      end
    end

    test "requires idempotency_key" do
      service = CheckoutService.new(payment_repository: FakeRepository.new, provider_resolver: FakeResolver.new(FakeAdapter.new(status: "pending")))

      error = assert_raises(ArgumentError) do
        service.call(
          registration: FakeRegistration.new(FakeTemple.new(1), nil),
          amount_cents: 1000,
          currency: "TWD",
          provider: "fake",
          idempotency_key: nil,
          intent_key: "reg-123"
        )
      end

      assert_equal "idempotency_key is required", error.message
    end

    test "returns existing completed intent as reused" do
      existing_payment = TemplePayment.new(status: TemplePayment::STATUSES[:completed])
      repository = FakeRepository.new(completed_for_intent: existing_payment)
      service = CheckoutService.new(payment_repository: repository, provider_resolver: FakeResolver.new(FakeAdapter.new(status: "pending")))

      result = service.call(
        registration: FakeRegistration.new(FakeTemple.new(1), nil),
        amount_cents: 1000,
        currency: "TWD",
        provider: "fake",
        idempotency_key: "idem-1",
        intent_key: "intent-1"
      )

      assert result.reused
      assert_equal existing_payment, result.payment
      assert_equal "duplicate_intent", result.adapter_payload[:reason]
    end

    test "checkout success maps to completed" do
      repository = FakeRepository.new
      service = CheckoutService.new(
        payment_repository: repository,
        provider_resolver: FakeResolver.new(FakeAdapter.new(status: "completed"))
      )

      result = service.call(
        registration: FakeRegistration.new(FakeTemple.new(1), nil),
        amount_cents: 1200,
        currency: "TWD",
        provider: "fake",
        idempotency_key: "idem-success",
        intent_key: "intent-success"
      )

      assert_equal TemplePayment::STATUSES[:completed], repository.applied_status
      assert_equal TemplePayment::STATUSES[:completed], result.payment.status
      assert_equal false, result.reused
    end

    test "ecpay checkout stays pending until provider confirmation" do
      repository = FakeRepository.new
      resolver = FakeResolver.new(FakeAdapter.new(status: "pending"))
      service = CheckoutService.new(
        payment_repository: repository,
        provider_resolver: resolver
      )
      temple = FakeTemple.new(1)

      result = service.call(
        registration: FakeRegistration.new(temple, nil),
        amount_cents: 1200,
        currency: "TWD",
        provider: "ecpay",
        idempotency_key: "idem-ecpay-pending",
        intent_key: "intent-ecpay-pending"
      )

      assert_equal "ecpay", repository.created_attrs[:provider]
      assert_equal TemplePayment::PAYMENT_METHODS[:ecpay], repository.created_attrs[:payment_method]
      assert_equal TemplePayment::STATUSES[:pending], repository.applied_status
      assert_equal TemplePayment::STATUSES[:pending], result.payment.status
      assert_equal "pay_ref_123", result.payment.provider_reference
      assert_equal "ecpay", resolver.resolved_provider
      assert_equal temple, resolver.resolved_kwargs[:temple]
      assert_equal false, result.reused
    end

    test "ecpay preflight rejects invalid currency and amount classes before any checkout mutation" do
      invalid_inputs = [
        [5000, "USD", Payments::Taiwan::EcpayAmount::InvalidCurrency],
        [nil, "TWD", Payments::Taiwan::EcpayAmount::InvalidAmount],
        ["not-an-amount", "TWD", Payments::Taiwan::EcpayAmount::InvalidAmount],
        [0, "TWD", Payments::Taiwan::EcpayAmount::InvalidAmount],
        [-5000, "TWD", Payments::Taiwan::EcpayAmount::InvalidAmount],
        [5050, "TWD", Payments::Taiwan::EcpayAmount::InvalidAmount]
      ]

      invalid_inputs.each_with_index do |(amount_cents, currency, error_class), index|
        repository = FakeRepository.new
        adapter = FakeAdapter.new(status: "pending")
        resolver = FakeResolver.new(adapter)
        service = CheckoutService.new(payment_repository: repository, provider_resolver: resolver)

        assert_raises(error_class, "invalid input #{index} must fail closed") do
          service.call(
            registration: FakeRegistration.new(FakeTemple.new(1), nil),
            amount_cents: amount_cents,
            currency: currency,
            provider: "ecpay",
            idempotency_key: "idem-invalid-#{index}",
            intent_key: "intent-invalid-#{index}"
          )
        end

        assert_equal 0, repository.idempotency_lookups
        assert_equal 0, repository.completed_intent_lookups
        assert_equal 0, repository.create_calls
        assert_equal 0, repository.apply_calls
        assert_equal 0, resolver.resolve_calls
        assert_equal 0, adapter.checkout_calls
      end
    end

    test "valid ecpay 5000 creates one internal pending payment and delegates one checkout" do
      repository = FakeRepository.new
      adapter = FakeAdapter.new(status: "pending")
      resolver = FakeResolver.new(adapter)
      service = CheckoutService.new(payment_repository: repository, provider_resolver: resolver)

      service.call(
        registration: FakeRegistration.new(FakeTemple.new(1), nil),
        amount_cents: 5000,
        currency: "TWD",
        provider: "ecpay",
        idempotency_key: "idem-ecpay-5000",
        intent_key: "intent-ecpay-5000"
      )

      assert_equal 1, repository.create_calls
      assert_equal 5000, repository.created_attrs[:amount_cents]
      assert_equal "TWD", repository.created_attrs[:currency]
      assert_equal 1, resolver.resolve_calls
      assert_equal 1, adapter.checkout_calls
      assert_equal 1, repository.apply_calls
    end

    test "invalid ECPay inputs leave every persisted payment and billing surface unchanged" do
      temple = create_temple
      offering = create_offering(temple:, price_cents: 5000, currency: "TWD")
      user = User.create!(
        email: "ecpay-preflight-#{SecureRandom.hex(4)}@example.com",
        english_name: "ECPay Preflight",
        encrypted_password: User.password_hash("Password123!")
      )
      registration = create_registration(user:, offering:)
      repository = Repositories::PaymentRepository.new
      adapter = FakeAdapter.new(status: "pending")
      service = CheckoutService.new(payment_repository: repository, provider_resolver: FakeResolver.new(adapter))
      counts = lambda do
        [
          TemplePayment.count,
          TempleRegistration.count,
          SystemAuditLog.count,
          PaymentWebhookLog.count,
          PlatformBillingStatement.count,
          PlatformBillingUsageRecord.count,
          PlatformBillingAdjustment.count
        ]
      end

      [
        [5000, "USD"], [nil, "TWD"], ["bad", "TWD"], [0, "TWD"], [-5000, "TWD"], [5050, "TWD"]
      ].each_with_index do |(amount_cents, currency), index|
        before = counts.call

        assert_raises(ArgumentError) do
          service.call(
            registration: registration,
            amount_cents: amount_cents,
            currency: currency,
            provider: "ecpay",
            idempotency_key: "idem-persisted-invalid-#{index}",
            intent_key: "intent-persisted-invalid-#{index}"
          )
        end

        assert_equal before, counts.call
        assert_equal TempleRegistration::PAYMENT_STATUSES[:pending], registration.reload.payment_status
      end
      assert_equal 0, adapter.checkout_calls
    end

    test "valid ECPay TWD 5000 serializes once and records one pending internal payment" do
      temple = create_temple
      offering = create_offering(temple:, price_cents: 5000, currency: "TWD")
      user = User.create!(
        email: "ecpay-wire-#{SecureRandom.hex(4)}@example.com",
        english_name: "ECPay Wire",
        encrypted_password: User.password_hash("Password123!")
      )
      registration = create_registration(user:, offering:)
      resolver = FakeResolver.new(PaymentGateway::EcpayAdapter.new(temple: temple))
      service = CheckoutService.new(provider_resolver: resolver)

      with_ecpay_env do
        assert_difference -> { TemplePayment.count }, 1 do
          result = service.call(
            registration: registration,
            amount_cents: 5000,
            currency: "TWD",
            provider: "ecpay",
            idempotency_key: "idem-persisted-ecpay-5000",
            intent_key: "intent-persisted-ecpay-5000",
            metadata: {
              browser_return_url: "https://example.test/return",
              server_callback_url: "https://example.test/webhooks/ecpay"
            }
          )

          assert_equal TemplePayment::STATUSES[:pending], result.payment.status
          assert_equal 5000, result.payment.amount_cents
          assert_equal "50", result.adapter_payload.dig(:raw, :ecpay_form_fields, "TotalAmount")
        end
      end

      assert_equal 1, resolver.resolve_calls
    end

    test "fake checkout reuse remains unchanged" do
      existing_payment = FakePayment.new(status: TemplePayment::STATUSES[:pending], metadata: {})
      repository = FakeRepository.new(existing_by_idempotency: existing_payment)
      adapter = FakeAdapter.new(status: "pending")
      resolver = FakeResolver.new(adapter)
      service = CheckoutService.new(payment_repository: repository, provider_resolver: resolver)

      result = service.call(
        registration: FakeRegistration.new(FakeTemple.new(1), nil),
        amount_cents: 5050,
        currency: "USD",
        provider: "fake",
        idempotency_key: "idem-fake-reuse",
        intent_key: "intent-fake-reuse"
      )

      assert result.reused
      assert_equal existing_payment, result.payment
      assert_equal 1, repository.idempotency_lookups
      assert_equal 0, repository.create_calls
      assert_equal 0, resolver.resolve_calls
      assert_equal 0, adapter.checkout_calls
    end

    test "checkout failure maps to failed" do
      repository = FakeRepository.new
      service = CheckoutService.new(
        payment_repository: repository,
        provider_resolver: FakeResolver.new(FakeAdapter.new(status: "failed"))
      )

      result = service.call(
        registration: FakeRegistration.new(FakeTemple.new(1), nil),
        amount_cents: 1200,
        currency: "TWD",
        provider: "fake",
        idempotency_key: "idem-failed",
        intent_key: "intent-failed"
      )

      assert_equal TemplePayment::STATUSES[:failed], repository.applied_status
      assert_equal TemplePayment::STATUSES[:failed], result.payment.status
      assert_equal false, result.reused
    end

    private

    def with_ecpay_env
      original = %w[ECPAY_MERCHANT_ID ECPAY_HASH_KEY ECPAY_HASH_IV].to_h { |key| [key, ENV[key]] }
      ENV["ECPAY_MERCHANT_ID"] = "2000132"
      ENV["ECPAY_HASH_KEY"] = "5294y06JbISpM5x9"
      ENV["ECPAY_HASH_IV"] = "v77hoKGq4kWxNNIS"
      yield
    ensure
      original.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    end
  end
end
