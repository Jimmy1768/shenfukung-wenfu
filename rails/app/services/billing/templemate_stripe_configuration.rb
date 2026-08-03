# frozen_string_literal: true

module Billing
  class TemplemateStripeConfiguration
    attr_reader :account_id, :setup_price_id, :monthly_price_id

    def initialize(configuration: Rails.configuration.x.stripe)
      @configuration = configuration
      @account_id = configuration.platform_account_id
      @setup_price_id = configuration.platform_setup_price_id
      @monthly_price_id = configuration.platform_monthly_price_id
    end

    def validate!
      values = [account_id, setup_price_id, monthly_price_id]
      raise ArgumentError, "TempleMate Stripe configuration is incomplete" if values.any?(&:blank?)
      raise ArgumentError, "TempleMate Stripe Prices must be distinct" if setup_price_id == monthly_price_id
      raise ArgumentError, "TempleMate Stripe account is invalid" unless account_id.to_s.start_with?("acct_")
      raise ArgumentError, "TempleMate Stripe setup Price is invalid" unless setup_price_id.to_s.start_with?("price_")
      raise ArgumentError, "TempleMate Stripe monthly Price is invalid" unless monthly_price_id.to_s.start_with?("price_")
      self
    end

    def webhook_secret
      @configuration.platform_webhook_secret
    end

    def stripe_options
      { stripe_account: account_id }
    end
  end
end
