# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class PaymentWebhooksTest < ActionDispatch::IntegrationTest
      test "fake webhook marks payment completed and registration paid" do
        temple = create_temple(slug: "webhook-temple")
        offering = create_offering(temple:, slug: "webhook-offering", price_cents: 1000)
        user = User.create!(
          email: "webhook-user@example.com",
          english_name: "Webhook User",
          encrypted_password: User.password_hash("Password123!")
        )
        registration = create_registration(user:, offering:)
        payment = create_payment(
          registration: registration,
          status: TemplePayment::STATUSES[:pending],
          method: TemplePayment::PAYMENT_METHODS[:cash],
          provider: "fake",
          provider_reference: "fake_ref_abc",
          processed_at: nil
        )

        post api_v1_payment_webhook_path(provider: "fake"),
          params: {
            event_type: "payment.updated",
            event_id: "evt_abc_1",
            provider_reference: payment.provider_reference,
            status: "completed",
            temple_slug: temple.slug
          }.to_json,
          headers: { "CONTENT_TYPE" => "application/json" }

        assert_response :success
        assert_equal TemplePayment::STATUSES[:completed], payment.reload.status
        assert_equal TempleRegistration::PAYMENT_STATUSES[:paid], registration.reload.payment_status
        assert SystemAuditLog.exists?(action: "system.payments.webhook_applied", target: payment)
        assert SystemAuditLog.exists?(action: "system.registrations.payment_status_updated", target: registration)
      end

      test "duplicate webhook event is ignored" do
        temple = create_temple(slug: "webhook-dup")
        create_offering(temple:, slug: "webhook-dup-offering", price_cents: 1000)
        PaymentWebhookLog.create!(
          temple: temple,
          provider: "fake",
          event_type: "payment.updated",
          provider_reference: "fake_ref_dup",
          provider_event_id: "evt_dup_1",
          payload: {},
          signature_valid: true,
          processed: true,
          received_at: Time.current,
          processed_at: Time.current
        )

        post api_v1_payment_webhook_path(provider: "fake"),
          params: {
            event_type: "payment.updated",
            event_id: "evt_dup_1",
            provider_reference: "fake_ref_dup",
            status: "completed",
            temple_slug: temple.slug
          }.to_json,
          headers: { "CONTENT_TYPE" => "application/json" }

        assert_response :success
        body = JSON.parse(response.body)
        assert_equal true, body["duplicate"]
      end

      test "a webhook cannot apply a payment from another temple with the same provider reference" do
        payment_temple = create_temple(slug: "webhook-payment-temple")
        callback_temple = create_temple(slug: "webhook-callback-temple")
        offering = create_offering(temple: payment_temple, slug: "webhook-isolated-offering", price_cents: 1000)
        user = User.create!(email: "webhook-isolated@example.com", english_name: "Webhook Isolated", encrypted_password: User.password_hash("Password123!"))
        registration = create_registration(user:, offering:)
        payment = create_payment(
          registration: registration,
          status: TemplePayment::STATUSES[:pending],
          method: TemplePayment::PAYMENT_METHODS[:cash],
          provider: "fake",
          provider_reference: "shared_fake_reference",
          processed_at: nil
        )

        post api_v1_payment_webhook_path(provider: "fake"), params: {
          event_type: "payment.updated",
          event_id: "evt_cross_tenant",
          provider_reference: payment.provider_reference,
          status: "completed",
          temple_slug: callback_temple.slug
        }.to_json, headers: { "CONTENT_TYPE" => "application/json" }

        assert_response :success
        assert_equal TemplePayment::STATUSES[:pending], payment.reload.status
        assert_equal TempleRegistration::PAYMENT_STATUSES[:pending], registration.reload.payment_status
        assert PaymentWebhookLog.exists?(temple: callback_temple, provider_reference: payment.provider_reference)
      end

      test "ecpay server callback marks payment completed and responds with plain ok" do
        temple = create_temple(slug: "ecpay-webhook-temple")
        offering = create_offering(temple:, slug: "ecpay-webhook-offering", price_cents: 1000)
        user = User.create!(
          email: "ecpay-webhook-user@example.com",
          english_name: "ECPay Webhook User",
          encrypted_password: User.password_hash("Password123!")
        )
        registration = create_registration(user:, offering:)
        payment = create_payment(
          registration: registration,
          status: TemplePayment::STATUSES[:pending],
          method: TemplePayment::PAYMENT_METHODS[:ecpay],
          provider: "ecpay",
          provider_reference: "TM1234567890ABCD",
          processed_at: nil
        )

        with_env(
          "ECPAY_MERCHANT_ID" => "2000132",
          "ECPAY_HASH_KEY" => "5294y06JbISpM5x9",
          "ECPAY_HASH_IV" => "v77hoKGq4kWxNNIS"
        ) do
          fields = {
            "MerchantID" => "2000132",
            "MerchantTradeNo" => payment.provider_reference,
            "RtnCode" => "1",
            "RtnMsg" => "Succeeded",
            "TradeNo" => "2404071234567890",
            "TradeAmt" => (payment.amount_cents / 100).to_s,
            "TradeStatus" => "1",
            "PaymentType" => "Credit_CreditCard",
            "CheckMacValue" => ""
          }
          fields["CheckMacValue"] = Payments::Taiwan::EcpayChecksum.generate(
            fields: fields,
            hash_key: ENV.fetch("ECPAY_HASH_KEY"),
            hash_iv: ENV.fetch("ECPAY_HASH_IV")
          )

          post api_v1_payment_webhook_path(provider: "ecpay", temple: temple.slug), params: fields
        end

        assert_response :success
        assert_equal "1|OK", response.body
        assert_equal TemplePayment::STATUSES[:completed], payment.reload.status
        assert_equal TempleRegistration::PAYMENT_STATUSES[:paid], registration.reload.payment_status
      end

      test "ecpay failed server callback does not mark payment received" do
        temple = create_temple(slug: "ecpay-webhook-failed-temple")
        offering = create_offering(temple:, slug: "ecpay-webhook-failed-offering", price_cents: 1000)
        user = User.create!(
          email: "ecpay-webhook-failed-user@example.com",
          english_name: "ECPay Webhook Failed User",
          encrypted_password: User.password_hash("Password123!")
        )
        registration = create_registration(user:, offering:)
        payment = create_payment(
          registration: registration,
          status: TemplePayment::STATUSES[:pending],
          method: TemplePayment::PAYMENT_METHODS[:ecpay],
          provider: "ecpay",
          provider_reference: "TMFAILED1234567",
          processed_at: nil
        )

        with_env(
          "ECPAY_MERCHANT_ID" => "2000132",
          "ECPAY_HASH_KEY" => "5294y06JbISpM5x9",
          "ECPAY_HASH_IV" => "v77hoKGq4kWxNNIS"
        ) do
          fields = {
            "MerchantID" => "2000132",
            "MerchantTradeNo" => payment.provider_reference,
            "RtnCode" => "0",
            "RtnMsg" => "Failed",
            "TradeNo" => "2404070000000000",
            "TradeAmt" => (payment.amount_cents / 100).to_s,
            "TradeStatus" => "0",
            "PaymentType" => "Credit_CreditCard",
            "CheckMacValue" => ""
          }
          fields["CheckMacValue"] = Payments::Taiwan::EcpayChecksum.generate(
            fields: fields,
            hash_key: ENV.fetch("ECPAY_HASH_KEY"),
            hash_iv: ENV.fetch("ECPAY_HASH_IV")
          )

          post api_v1_payment_webhook_path(provider: "ecpay", temple: temple.slug), params: fields
        end

        assert_response :success
        assert_equal "1|OK", response.body
        assert_equal TemplePayment::STATUSES[:failed], payment.reload.status
        assert_equal TempleRegistration::PAYMENT_STATUSES[:failed], registration.reload.payment_status
        assert_nil payment.processed_at
      end

      test "a signed ECPay TradeAmt mismatch fails before payment, registration, or audit mutation" do
        temple = create_temple(slug: "ecpay-webhook-amount-mismatch")
        offering = create_offering(temple:, slug: "ecpay-webhook-amount-offering", price_cents: 5000)
        user = User.create!(email: "ecpay-amount-mismatch@example.com", english_name: "ECPay Amount Mismatch", encrypted_password: User.password_hash("Password123!"))
        registration = create_registration(user:, offering:)
        payment = create_payment(
          registration: registration,
          status: TemplePayment::STATUSES[:pending],
          method: TemplePayment::PAYMENT_METHODS[:ecpay],
          provider: "ecpay",
          provider_reference: "TMAMOUNTMISMATCH",
          processed_at: nil
        )

        with_env(
          "ECPAY_MERCHANT_ID" => "2000132",
          "ECPAY_HASH_KEY" => "5294y06JbISpM5x9",
          "ECPAY_HASH_IV" => "v77hoKGq4kWxNNIS"
        ) do
          fields = {
            "MerchantID" => "2000132", "MerchantTradeNo" => payment.provider_reference,
            "RtnCode" => "1", "TradeNo" => "2404079999999999", "TradeAmt" => "49",
            "TradeStatus" => "1", "CheckMacValue" => ""
          }
          fields["CheckMacValue"] = Payments::Taiwan::EcpayChecksum.generate(
            fields: fields, hash_key: ENV.fetch("ECPAY_HASH_KEY"), hash_iv: ENV.fetch("ECPAY_HASH_IV")
          )

          assert_no_difference -> { PaymentWebhookLog.count } do
            assert_no_difference -> { SystemAuditLog.count } do
              post api_v1_payment_webhook_path(provider: "ecpay", temple: temple.slug), params: fields
            end
          end
        end

        assert_response :unprocessable_entity
        assert_equal "0|invalid_request", response.body
        assert_equal TemplePayment::STATUSES[:pending], payment.reload.status
        assert_equal TempleRegistration::PAYMENT_STATUSES[:pending], registration.reload.payment_status
      end

      private

      def with_env(overrides)
        original = overrides.each_with_object({}) { |(key, _), result| result[key] = ENV[key] }
        overrides.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
        yield
      ensure
        original.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
      end
    end
  end
end
