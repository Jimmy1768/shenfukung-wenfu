# frozen_string_literal: true

module Payments
  class RefundService
    Result = Struct.new(:payment, :adapter_payload, keyword_init: true)

    def initialize(provider_resolver: ProviderResolver, payment_repository: Repositories::PaymentRepository.new)
      @provider_resolver = provider_resolver
      @payment_repository = payment_repository
    end

    def call(payment:, amount_cents: nil, reason: nil, idempotency_key:, operation: :refund)
      raise ArgumentError, "idempotency_key is required" if idempotency_key.blank?
      assert_full_refund!(payment:, amount_cents:, operation:)

      adapter_payload = if operation.to_sym == :cancel
        adapter(payment.provider).cancel(
          payment_reference: payment.provider_reference.presence || payment.external_reference.presence || payment.id.to_s,
          reason: reason,
          idempotency_key: idempotency_key
        )
      else
        adapter(payment.provider).refund(
          payment_reference: payment.provider_reference.presence || payment.external_reference.presence || payment.id.to_s,
          amount_cents: amount_cents,
          reason: reason,
          idempotency_key: idempotency_key
        )
      end

      if adapter_payload[:status].to_s == "partial_refunded"
        raise Payments::StatusMapper::UnsupportedPartialRefund, "Partial refunds are not supported"
      end

      payment_repository.update_status!(
        payment: payment,
        status: Payments::StatusMapper.map(
          adapter_payload[:status],
          aliases: {
            TemplePayment::STATUSES[:refunded] => %w[refunded],
            TemplePayment::STATUSES[:failed] => %w[canceled cancelled failed error declined]
          },
          fallback: TemplePayment::STATUSES[:failed]
        ),
        payload: adapter_payload,
        metadata: {
          refund_reason: reason,
          operation: operation.to_sym
        }.compact
      )
      Payments::RegistrationPaymentSync.call(payment)
      log_refund_event!(
        payment: payment,
        operation: operation,
        reason: reason
      )

      Result.new(payment: payment, adapter_payload: adapter_payload)
    end

    private

    attr_reader :provider_resolver, :payment_repository

    def adapter(provider)
      provider_resolver.resolve(provider: provider)
    end

    def assert_full_refund!(payment:, amount_cents:, operation:)
      return unless operation.to_sym == :refund
      return if amount_cents.blank? || payment.amount_cents.blank?
      return if amount_cents.to_i == payment.amount_cents.to_i

      raise Payments::StatusMapper::UnsupportedPartialRefund, "Partial refunds are not supported"
    end

    def log_refund_event!(payment:, operation:, reason:)
      action =
        if operation.to_sym == :cancel
          "system.payments.cancelled"
        else
          "system.payments.refunded"
        end

      SystemAuditLogger.log!(
        action: action,
        target: payment,
        temple: payment.temple,
        metadata: {
          actor_type: "system",
          payment_id: payment.id,
          payment_reference: payment.provider_reference.presence || payment.id,
          registration_reference: payment.temple_registration&.reference_code,
          provider: payment.provider,
          source: "refund_service",
          operation: operation.to_sym,
          reason: reason,
          current_status: payment.status
        }.compact
      )
    end
  end
end
