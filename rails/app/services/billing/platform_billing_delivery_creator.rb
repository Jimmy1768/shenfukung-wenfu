# frozen_string_literal: true

module Billing
  class PlatformBillingDeliveryCreator
    def self.create_monthly!(...) = new(...).create_monthly!

    def initialize(statement:)
      @statement = statement
    end

    def create_monthly!
      raise ArgumentError, "Statement must be closed" unless statement.status == "closed"
      statement.platform_billing_delivery || PlatformBillingDelivery.create!(
        temple: statement.temple, platform_billing_statement: statement, kind: "monthly", status: "pending",
        period_start_at: statement.period_start_at, period_end_at: statement.period_end_at,
        pricing_policy_version: statement.pricing_policy_version, currency: statement.currency,
        registration_count: statement.registration_count, adjustment_total_cents: statement.adjustment_total_cents,
        total_cents: statement.total_cents, idempotency_key: "platform-monthly:#{statement.idempotency_key}"
      )
    rescue ActiveRecord::RecordNotUnique
      PlatformBillingDelivery.find_by!(platform_billing_statement: statement)
    end

    private

    attr_reader :statement
  end
end
