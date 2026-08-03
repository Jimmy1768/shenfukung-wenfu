# frozen_string_literal: true

require "cgi"

module Billing
  class StripePaymentMethodSetup
    Result = Struct.new(:session_id, :url, :payload, keyword_init: true)
    class LegacyAnnualStripeBillingRecordError < StandardError; end

    def self.start(...) = new(...).start
    def self.complete(...) = new(...).complete

    def initialize(temple:, admin:, success_url: nil, cancel_url: nil, checkout_session_id: nil)
      @temple, @admin, @success_url, @cancel_url, @checkout_session_id = temple, admin, success_url, cancel_url, checkout_session_id
    end

    def start
      reject_legacy_annual_stripe_billing_record!
      configuration.validate!
      delivery = temple.platform_billing_deliveries.find_or_create_by!(kind: "setup", status: "pending") do |record|
        record.assign_attributes(currency: "TWD", total_cents: 1_000_000, idempotency_key: "platform-setup:#{temple.id}")
      end
      session = Stripe::Checkout::Session.create({ mode: "payment", customer: temple.billing_settings["stripe_customer_id"].presence,
        customer_email: temple.billing_settings["stripe_customer_id"].present? ? nil : admin.email,
        client_reference_id: temple.id.to_s, success_url: append_checkout_session_id(success_url), cancel_url: cancel_url,
        line_items: [{ price: configuration.setup_price_id, quantity: 1 }], payment_intent_data: { setup_future_usage: "off_session", metadata: metadata(delivery) },
        metadata: metadata(delivery) }.compact, configuration.stripe_options.merge(idempotency_key: delivery.idempotency_key))
      delivery.update!(provider_reference: session.id)
      Result.new(session_id: session.id, url: session.url, payload: session.to_hash)
    end

    def complete
      reject_legacy_annual_stripe_billing_record!
      configuration.validate!
      session = Stripe::Checkout::Session.retrieve({ id: checkout_session_id, expand: ["customer", "payment_intent.payment_method"] }, configuration.stripe_options)
      raise ArgumentError, "Stripe setup payment was not paid" unless session.payment_status == "paid" && session.mode == "payment"
      raise ArgumentError, "Stripe setup belongs to another temple" unless session.client_reference_id.to_s == temple.id.to_s && session.metadata["purpose"] == "templemate_platform_setup"
      customer = session.customer
      payment_method = session.payment_intent.payment_method
      raise ArgumentError, "Stripe did not return a payment method" unless customer.respond_to?(:id) && payment_method.respond_to?(:id)
      delivery = temple.platform_billing_deliveries.find_by!(kind: "setup", provider_reference: session.id)
      settings = temple.payment_provider_settings.is_a?(Hash) ? temple.payment_provider_settings.deep_dup : {}
      settings["billing"] = temple.billing_settings.merge("provider" => "stripe", "stripe_customer_id" => customer.id,
        "stripe_payment_method_id" => payment_method.id, "last_setup_at" => Time.current.iso8601, "last_stripe_checkout_session_id" => session.id)
      Temple.transaction do
        temple.update!(payment_provider_settings: settings)
        delivery.update!(status: "paid", provider_customer_id: customer.id, provider_payment_method_id: payment_method.id)
        SystemAuditLogger.log!(action: "admin.payment_methods.platform_setup_completed", admin:, target: temple, temple:,
          metadata: { provider: "stripe", setup_delivery_id: delivery.id, provider_reference: session.id })
      end
      Result.new(session_id: session.id, url: nil, payload: session.to_hash)
    end

    private

    attr_reader :temple, :admin, :success_url, :cancel_url, :checkout_session_id

    def reject_legacy_annual_stripe_billing_record!
      billing = temple.billing_settings
      has_legacy_subscription_reference = billing["stripe_subscription_id"].present? || billing["stripe_subscription_reference"].present?
      has_legacy_annual_terms = billing["billing_interval"] == "year" ||
        (billing["billing_interval_months"].to_i == 12 && billing["annual_fee_cents"].present?)

      return unless has_legacy_subscription_reference && has_legacy_annual_terms

      raise LegacyAnnualStripeBillingRecordError,
        "Legacy annual Stripe billing records cannot use the platform setup flow"
    end

    def configuration = TemplemateStripeConfiguration.new
    def metadata(delivery) = { temple_id: temple.id.to_s, delivery_id: delivery.id.to_s, purpose: "templemate_platform_setup" }
    def append_checkout_session_id(url)
      uri = URI.parse(url); params = CGI.parse(uri.query.to_s).transform_values(&:last); params["checkout_session_id"] = "{CHECKOUT_SESSION_ID}"
      uri.query = params.map { |key, value| "#{CGI.escape(key.to_s)}=#{value == "{CHECKOUT_SESSION_ID}" ? value : CGI.escape(value.to_s)}" }.join("&")
      uri.to_s
    end
  end
end
