# frozen_string_literal: true

require "test_helper"

module Payments
  class ProviderResolverTest < ActiveSupport::TestCase
    test "test environment defaults to fake checkout" do
      with_env("PAYMENTS_PROVIDER" => nil) do
        assert_equal "fake", ProviderResolver.current_provider
        assert_instance_of PaymentGateway::FakeAdapter, ProviderResolver.resolve
      end
    end

    test "non-test local environments default to ecpay" do
      with_env("PAYMENTS_PROVIDER" => nil) do
        Rails.env.stub(:test?, false) do
          assert_equal "ecpay", ProviderResolver.current_provider
          assert_instance_of PaymentGateway::EcpayAdapter, ProviderResolver.resolve
        end
      end
    end

    test "explicit provider override wins" do
      with_env("PAYMENTS_PROVIDER" => "fake") do
        Rails.env.stub(:test?, false) do
          assert_equal "fake", ProviderResolver.current_provider
        end
      end
    end

    test "two temples resolve independent configured providers without changing the process environment" do
      fake_temple = create_temple(payment_provider_settings: { "patron_checkout_provider" => "fake" })
      ecpay_temple = create_temple(payment_provider_settings: {
        "patron_checkout_provider" => "ecpay",
        "ecpay" => { "merchant_id" => "tenant-ecpay" }
      })

      with_env("PAYMENTS_PROVIDER" => "fake") do
        fake_adapter = ProviderResolver.resolve(temple: fake_temple)
        ecpay_adapter = ProviderResolver.resolve(temple: ecpay_temple)

        assert_instance_of PaymentGateway::FakeAdapter, fake_adapter
        assert_instance_of PaymentGateway::EcpayAdapter, ecpay_adapter
        assert_equal ecpay_temple, ecpay_adapter.instance_variable_get(:@temple)
      end
    end

    test "explicit historical provider wins after tenant selection changes" do
      temple = create_temple(payment_provider_settings: { "patron_checkout_provider" => "fake" })

      assert_instance_of PaymentGateway::FakeAdapter, ProviderResolver.resolve(temple: temple)

      temple.update!(payment_provider_settings: { "patron_checkout_provider" => "ecpay" })

      adapter = ProviderResolver.resolve(provider: "fake", temple: temple)
      assert_instance_of PaymentGateway::FakeAdapter, adapter
    end

    test "invalid tenant provider selection fails closed" do
      temple = create_temple(payment_provider_settings: { "patron_checkout_provider" => "unsupported" })

      error = assert_raises(ArgumentError) { ProviderResolver.resolve(temple: temple) }
      assert_equal "Unsupported payments provider: unsupported", error.message
    end

    test "invalid process provider selection fails closed when no tenant selection exists" do
      temple = create_temple(payment_provider_settings: {})

      with_env("PAYMENTS_PROVIDER" => "unsupported") do
        error = assert_raises(ArgumentError) { ProviderResolver.resolve(temple: temple) }
        assert_equal "Unsupported payments provider: unsupported", error.message
      end
    end

    test "invalid temple context fails closed instead of using a process fallback" do
      error = assert_raises(ArgumentError) { ProviderResolver.resolve(temple: Object.new) }
      assert_equal "Invalid payments temple context", error.message
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
