require "test_helper"

class Billing::PlatformPricingPolicyTest < ActiveSupport::TestCase
  test "quotes the agreed progressive bands without a pricing cliff" do
    assert_equal 150_000, Billing::PlatformPricingPolicy.quote(500).usage_total_cents
    assert_equal 300_000, Billing::PlatformPricingPolicy.quote(2_000).usage_total_cents

    quote = Billing::PlatformPricingPolicy.quote(10_000)

    assert_equal 10_000, quote.registration_count
    assert_equal 500, quote.included_registration_count
    assert_equal 1_500, quote.band_one_registration_count
    assert_equal 8_000, quote.band_two_registration_count
    assert_equal 0, quote.band_three_registration_count
    assert_equal 1_300_000, quote.usage_total_cents
  end

  test "charges the higher rate only for registrations above ten thousand" do
    quote = Billing::PlatformPricingPolicy.quote(15_000)

    assert_equal 5_000, quote.band_three_registration_count
    assert_equal 750_000, quote.band_three_fee_cents
    assert_equal 2_050_000, quote.usage_total_cents
  end
end
