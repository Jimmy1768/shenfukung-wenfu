# frozen_string_literal: true

module Payments
  class ProviderResolver
    Availability = Data.define(:online?, :provider, :reason)
    OnlineCheckoutUnavailable = Class.new(StandardError)

    PROVIDERS = {
      "fake" => PaymentGateway::FakeAdapter,
      "ecpay" => PaymentGateway::EcpayAdapter
    }.freeze

    PROVIDER_LABELS = {
      "fake" => "test checkout",
      "ecpay" => "ECPay"
    }.freeze

    TENANT_PROVIDER_SETTING = "patron_checkout_provider"
    CASH_ONLY_SELECTION = "cash_only"

    def self.current_provider
      validate_provider!(ENV.fetch("PAYMENTS_PROVIDER", default_provider).to_s)
    end

    def self.provider_for(temple:)
      availability_for(temple:).provider || raise(OnlineCheckoutUnavailable, "Online checkout is unavailable for this temple")
    end

    def self.availability_for(temple:)
      selection = configured_selection_for(temple)
      return Availability.new(online?: false, provider: nil, reason: :cash_only) if selection == CASH_ONLY_SELECTION

      Availability.new(online?: true, provider: selection || current_provider, reason: nil)
    end

    def self.online_checkout_available?(temple:)
      availability_for(temple:).online?
    end

    def self.require_online_checkout!(temple:)
      availability = availability_for(temple:)
      return availability.provider if availability.online?

      raise OnlineCheckoutUnavailable, "Online checkout is unavailable for this temple"
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

    def self.configured_selection_for(temple)
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
      return CASH_ONLY_SELECTION if selection.to_s == CASH_ONLY_SELECTION

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
    private_class_method :configured_selection_for, :default_provider, :validate_provider!
  end
end
