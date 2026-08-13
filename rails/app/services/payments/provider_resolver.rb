# frozen_string_literal: true

module Payments
  class ProviderResolver
    PROVIDERS = {
      "fake" => PaymentGateway::FakeAdapter,
      "ecpay" => PaymentGateway::EcpayAdapter
    }.freeze

    PROVIDER_LABELS = {
      "fake" => "test checkout",
      "ecpay" => "ECPay"
    }.freeze

    TENANT_PROVIDER_SETTING = "patron_checkout_provider"

    def self.current_provider
      validate_provider!(ENV.fetch("PAYMENTS_PROVIDER", default_provider).to_s)
    end

    def self.provider_for(temple:)
      configured_provider_for(temple) || current_provider
    end

    def self.label_for(provider)
      PROVIDER_LABELS.fetch(provider.to_s, provider.to_s.humanize)
    end

    def self.resolve(provider: nil, temple: nil)
      key = provider.presence ? validate_provider!(provider) : provider_for(temple: temple)
      adapter_class = PROVIDERS[key]

      if adapter_class.instance_method(:initialize).parameters.any? { |type, name| [:key, :keyreq].include?(type) && name == :temple }
        adapter_class.new(temple: temple)
      else
        adapter_class.new
      end
    end

    def self.configured_provider_for(temple)
      return if temple.nil?

      unless temple.respond_to?(:payment_provider_settings)
        raise ArgumentError, "Invalid payments temple context"
      end

      settings = temple.payment_provider_settings
      unless settings.is_a?(Hash)
        raise ArgumentError, "Invalid payments provider settings"
      end

      selection = settings[TENANT_PROVIDER_SETTING] || settings[TENANT_PROVIDER_SETTING.to_sym]
      return if selection.blank?

      validate_provider!(selection)
    end

    def self.default_provider
      Rails.env.test? ? "fake" : "ecpay"
    end

    def self.validate_provider!(provider)
      key = provider.to_s
      raise ArgumentError, "Unsupported payments provider: #{key}" unless PROVIDERS.key?(key)

      key
    end
    private_class_method :configured_provider_for, :default_provider, :validate_provider!
  end
end
