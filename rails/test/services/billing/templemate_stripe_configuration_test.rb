require "test_helper"
class Billing::TemplemateStripeConfigurationTest < ActiveSupport::TestCase
  test "requires the configured account and distinct catalog IDs" do
    config = Struct.new(:platform_account_id, :platform_setup_price_id, :platform_monthly_price_id, :platform_webhook_secret).new("acct_1TFRmE7ZKypwRK7g", "price_1U0Ix77ZKypwRK7gI1x3IngL", "price_1U0J5S7ZKypwRK7gRvFaJd4D")
    subject = Billing::TemplemateStripeConfiguration.new(configuration: config)
    assert subject.validate!
    assert_equal({ stripe_account: "acct_1TFRmE7ZKypwRK7g" }, subject.stripe_options)
    config.platform_monthly_price_id = config.platform_setup_price_id
    assert_raises(ArgumentError) { Billing::TemplemateStripeConfiguration.new(configuration: config).validate! }
  end
end
