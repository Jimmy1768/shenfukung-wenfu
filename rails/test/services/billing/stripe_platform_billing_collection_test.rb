require "test_helper"
class Billing::StripePlatformBillingCollectionTest < ActiveSupport::TestCase
  Invoice = Struct.new(:id, :amount_due, :due_date, keyword_init: true)
  test "sends finalized 600-registration statement as one monthly collection" do
    temple = create_temple(payment_provider_settings: { "billing" => { "stripe_customer_id" => "cus_1" } })
    statement = temple.platform_billing_statements.create!(period_start_at: 2.months.ago.beginning_of_month, period_end_at: 1.month.ago.beginning_of_month,
      pricing_policy_version: "v1", currency: "TWD", status: "closed", idempotency_key: "statement-1", registration_count: 600, included_registration_count: 500,
      band_one_registration_count: 100, band_two_registration_count: 0, band_three_registration_count: 0, base_fee_cents: 150_000, band_one_fee_cents: 10_000,
      band_two_fee_cents: 0, band_three_fee_cents: 0, usage_total_cents: 160_000, total_cents: 160_000, closed_at: Time.current)
    delivery = Billing::PlatformBillingDeliveryCreator.create_monthly!(statement:)
    with_config do
      Stripe::InvoiceItem.stub(:create, ->(args, options) { @item_args = args; @item_options = options; Object.new }) do
        Stripe::Invoice.stub(:create, ->(args, options) { @invoice_args = args; @invoice_options = options; Invoice.new(id: "in_1", amount_due: 160_000) }) do
          Billing::StripePlatformBillingCollection.collect!(delivery:)
        end
      end
    end
    assert_equal "collecting", delivery.reload.status
    assert_equal "in_1", delivery.provider_reference
    assert_equal "price_monthly", @item_args.dig(:pricing, :price)
    assert_equal "charge_automatically", @invoice_args[:collection_method]
    assert_equal "TWD", delivery.currency
    assert_equal "acct_test", @invoice_options[:stripe_account]
  end
  private
  def with_config
    c = Rails.configuration.x.stripe; old = [c.platform_account_id, c.platform_setup_price_id, c.platform_monthly_price_id]
    c.platform_account_id, c.platform_setup_price_id, c.platform_monthly_price_id = "acct_test", "price_setup", "price_monthly"; yield
  ensure c.platform_account_id, c.platform_setup_price_id, c.platform_monthly_price_id = old end
end
