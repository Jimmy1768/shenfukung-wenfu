# frozen_string_literal: true

module Billing
  class StripePlatformBillingCollection
    def self.collect!(...) = new(...).collect!

    def initialize(delivery:)
      @delivery = delivery
    end

    def collect!
      raise ArgumentError, "Only pending monthly deliveries can be collected" unless delivery.kind == "monthly" && delivery.status == "pending"
      configuration.validate!
      customer = delivery.temple.billing_settings["stripe_customer_id"].presence
      raise ArgumentError, "Verified Stripe customer is required" if customer.blank?

      options = configuration.stripe_options.merge(idempotency_key: delivery.idempotency_key)
      Stripe::InvoiceItem.create({ customer:, pricing: { price: configuration.monthly_price_id }, quantity: delivery.registration_count,
        metadata: provider_metadata }.compact, options)
      add_adjustment_items(customer, options)
      invoice = Stripe::Invoice.create({ customer:, collection_method: "charge_automatically", auto_advance: true,
        metadata: provider_metadata }.compact, options.merge(idempotency_key: "#{delivery.idempotency_key}:invoice"))
      amount = invoice.respond_to?(:amount_due) ? invoice.amount_due : invoice[:amount_due]
      raise ArgumentError, "Stripe invoice total does not match Wenfu statement" unless amount.to_i == delivery.total_cents

      delivery.update!(status: "collecting", provider_customer_id: customer, provider_reference: invoice.id,
        due_at: invoice.respond_to?(:due_date) && invoice.due_date ? Time.at(invoice.due_date) : nil)
      delivery
    end

    private

    attr_reader :delivery

    def configuration = TemplemateStripeConfiguration.new

    def provider_metadata
      { temple_id: delivery.temple_id.to_s, delivery_id: delivery.id.to_s, purpose: "templemate_platform_monthly" }
    end

    def add_adjustment_items(customer, options)
      return if delivery.adjustment_total_cents.zero?
      Stripe::InvoiceItem.create({ customer:, price_data: { currency: delivery.currency.downcase,
        product_data: { name: "TempleMate registration adjustment" }, unit_amount: delivery.adjustment_total_cents }, quantity: 1,
        metadata: provider_metadata.merge(adjustment: "true") }, options.merge(idempotency_key: "#{delivery.idempotency_key}:adjustment"))
    end
  end
end
