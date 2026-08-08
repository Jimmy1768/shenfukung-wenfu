require "test_helper"

class Billing::StripePaymentMethodSetupTest < ActiveSupport::TestCase
  Session = Struct.new(:id, :url, :mode, :payment_status, :client_reference_id, :metadata, :customer, :payment_intent, keyword_init: true) { def to_hash = { "id" => id } }
  Ref = Struct.new(:id, :payment_method, keyword_init: true)

  test "setup uses the one-time setup price, never a subscription" do
    temple = create_temple; admin = create_admin_user(temple:)
    with_configuration do
      Stripe::Checkout::Session.stub(:create, ->(args, options) { @args = args; @options = options; Session.new(id: "cs_1", url: "https://checkout.test") }) do
        Billing::StripePaymentMethodSetup.start(temple:, admin:, success_url: "https://example.test/ok", cancel_url: "https://example.test/no")
      end
    end
    assert_equal "payment", @args[:mode]
    assert_equal "price_setup", @args[:line_items].first[:price]
    assert_equal "acct_test", @options[:stripe_account]
    refute @args.key?(:subscription_data)
    assert_equal "pending_setup", temple.reload.platform_billing_entitlement.state
  end

  test "setup start retains an already adopted pending entitlement" do
    temple = create_temple
    admin = create_admin_user(temple:)
    entitlement = temple.adopt_platform_billing_entitlement!

    with_configuration do
      Stripe::Checkout::Session.stub(:create, Session.new(id: "cs_existing", url: "https://checkout.test")) do
        Billing::StripePaymentMethodSetup.start(temple:, admin:, success_url: "https://example.test/ok", cancel_url: "https://example.test/no")
      end
    end

    assert_equal entitlement.id, temple.reload.platform_billing_entitlement.id
    assert_equal 1, PlatformBillingEntitlement.where(temple:).count
    assert_equal "pending_setup", entitlement.reload.state
  end

  test "setup completion retrieves through the configured Stripe account" do
    temple = create_temple
    admin = create_admin_user(temple:)
    temple.adopt_platform_billing_entitlement!
    temple.platform_billing_deliveries.create!(kind: "setup", status: "pending", currency: "TWD", total_cents: 1_000_000, idempotency_key: "platform-setup:#{temple.id}", provider_reference: "cs_complete")
    session = Session.new(id: "cs_complete", mode: "payment", payment_status: "paid", client_reference_id: temple.id.to_s,
      metadata: { "purpose" => "templemate_platform_setup" }, customer: Ref.new(id: "cus_1"), payment_intent: Ref.new(payment_method: Ref.new(id: "pm_1")))

    with_configuration do
      Stripe::Checkout::Session.stub(:retrieve, ->(_args, options) { @retrieve_options = options; session }) do
        Billing::StripePaymentMethodSetup.complete(temple:, admin:, checkout_session_id: "cs_complete")
      end
    end

    assert_equal "acct_test", @retrieve_options[:stripe_account]
    assert_equal "pm_1", temple.reload.billing_settings["stripe_payment_method_id"]
    assert_equal "active", temple.platform_billing_entitlement.state
    assert_equal temple.platform_billing_deliveries.find_by!(provider_reference: "cs_complete"),
      temple.platform_billing_entitlement.platform_billing_delivery
  end

  test "missing, unpaid, and cross-tenant setup completions do not activate entitlement" do
    temple = create_temple
    other_temple = create_temple
    admin = create_admin_user(temple:)
    temple.adopt_platform_billing_entitlement!
    delivery = temple.platform_billing_deliveries.create!(kind: "setup", status: "pending", currency: "TWD", total_cents: 1_000_000,
      idempotency_key: "platform-setup:#{temple.id}", provider_reference: "cs_unverified")

    with_configuration do
      error = assert_raises(ArgumentError) do
        Billing::StripePaymentMethodSetup.complete(temple:, admin:, checkout_session_id: nil)
      end
      assert_match "checkout session is required", error.message

      unpaid_session = setup_session(id: delivery.provider_reference, temple:, payment_status: "unpaid")
      Stripe::Checkout::Session.stub(:retrieve, unpaid_session) do
        assert_raises(ArgumentError) do
          Billing::StripePaymentMethodSetup.complete(temple:, admin:, checkout_session_id: delivery.provider_reference)
        end
      end

      cross_tenant_session = setup_session(id: delivery.provider_reference, temple: other_temple)
      Stripe::Checkout::Session.stub(:retrieve, cross_tenant_session) do
        assert_raises(ArgumentError) do
          Billing::StripePaymentMethodSetup.complete(temple:, admin:, checkout_session_id: delivery.provider_reference)
        end
      end
    end

    assert_equal "pending_setup", temple.reload.platform_billing_entitlement.state
    assert_equal "pending", delivery.reload.status
  end

  test "legacy annual Stripe record rejects setup start without side effects" do
    temple = legacy_annual_stripe_temple
    admin = create_admin_user(temple:)

    assert_legacy_record_is_unchanged(temple) do
      Stripe::Checkout::Session.stub(:create, ->(*) { flunk "Stripe Checkout create must not be invoked" }) do
        error = assert_raises(Billing::StripePaymentMethodSetup::LegacyAnnualStripeBillingRecordError) do
          Billing::StripePaymentMethodSetup.start(temple:, admin:, success_url: "https://example.test/ok", cancel_url: "https://example.test/no")
        end

        assert_match "Legacy annual Stripe billing records", error.message
      end
    end
  end

  test "legacy annual Stripe record rejects setup completion without side effects" do
    temple = legacy_annual_stripe_temple
    admin = create_admin_user(temple:)

    assert_legacy_record_is_unchanged(temple) do
      Stripe::Checkout::Session.stub(:retrieve, ->(*) { flunk "Stripe Checkout retrieve must not be invoked" }) do
        error = assert_raises(Billing::StripePaymentMethodSetup::LegacyAnnualStripeBillingRecordError) do
          Billing::StripePaymentMethodSetup.complete(temple:, admin:, checkout_session_id: "cs_legacy_annual")
        end

        assert_match "Legacy annual Stripe billing records", error.message
      end
    end
  end

  private

  def legacy_annual_stripe_temple
    create_temple(payment_provider_settings: {
      "billing" => {
        "provider" => "stripe",
        "stripe_customer_id" => "cus_legacy_annual",
        "stripe_subscription_id" => "sub_legacy_annual",
        "stripe_payment_method_id" => "pm_legacy_annual",
        "payment_method_on_file" => true,
        "monthly_fee_cents" => 300_000,
        "annual_fee_cents" => 3_600_000,
        "billing_interval" => "year",
        "billing_interval_months" => 12,
        "grace_days" => 30,
        "grace_started_at" => "2026-08-01T00:00:00+08:00"
      }
    })
  end

  def assert_legacy_record_is_unchanged(temple)
    legacy_settings = temple.payment_provider_settings.deep_dup
    counts = [PlatformBillingDelivery.count, PlatformBillingEvent.count, SystemAuditLog.count]

    yield

    temple.reload
    assert_equal legacy_settings, temple.payment_provider_settings
    assert_equal counts, [PlatformBillingDelivery.count, PlatformBillingEvent.count, SystemAuditLog.count]
  end

  def with_configuration
    c = Rails.configuration.x.stripe
    old = [c.platform_account_id, c.platform_setup_price_id, c.platform_monthly_price_id]
    c.platform_account_id, c.platform_setup_price_id, c.platform_monthly_price_id = "acct_test", "price_setup", "price_monthly"
    yield
  ensure
    c.platform_account_id, c.platform_setup_price_id, c.platform_monthly_price_id = old
  end

  def setup_session(id:, temple:, payment_status: "paid")
    Session.new(id:, mode: "payment", payment_status:, client_reference_id: temple.id.to_s,
      metadata: { "purpose" => "templemate_platform_setup" }, customer: Ref.new(id: "cus_1"),
      payment_intent: Ref.new(payment_method: Ref.new(id: "pm_1")))
  end
end
