# frozen_string_literal: true

module Billing
  class PlatformPricingPolicy
    VERSION = "temple_platform_usage_v1".freeze
    CURRENCY = "TWD".freeze
    SETUP_FEE_CENTS = 1_000_000
    BASE_FEE_CENTS = 150_000
    INCLUDED_REGISTRATIONS = 500
    BAND_ONE_LIMIT = 2_000
    BAND_TWO_LIMIT = 10_000
    BAND_ONE_UNIT_FEE_CENTS = 100
    BAND_TWO_UNIT_FEE_CENTS = 125
    BAND_THREE_UNIT_FEE_CENTS = 150

    Quote = Data.define(
      :registration_count,
      :included_registration_count,
      :band_one_registration_count,
      :band_two_registration_count,
      :band_three_registration_count,
      :base_fee_cents,
      :band_one_fee_cents,
      :band_two_fee_cents,
      :band_three_fee_cents,
      :usage_total_cents
    )

    def self.quote(registration_count)
      count = [registration_count.to_i, 0].max
      band_one_count = [[count - INCLUDED_REGISTRATIONS, 0].max, BAND_ONE_LIMIT - INCLUDED_REGISTRATIONS].min
      band_two_count = [[count - BAND_ONE_LIMIT, 0].max, BAND_TWO_LIMIT - BAND_ONE_LIMIT].min
      band_three_count = [count - BAND_TWO_LIMIT, 0].max

      Quote.new(
        registration_count: count,
        included_registration_count: [count, INCLUDED_REGISTRATIONS].min,
        band_one_registration_count: band_one_count,
        band_two_registration_count: band_two_count,
        band_three_registration_count: band_three_count,
        base_fee_cents: BASE_FEE_CENTS,
        band_one_fee_cents: band_one_count * BAND_ONE_UNIT_FEE_CENTS,
        band_two_fee_cents: band_two_count * BAND_TWO_UNIT_FEE_CENTS,
        band_three_fee_cents: band_three_count * BAND_THREE_UNIT_FEE_CENTS,
        usage_total_cents: BASE_FEE_CENTS +
          (band_one_count * BAND_ONE_UNIT_FEE_CENTS) +
          (band_two_count * BAND_TWO_UNIT_FEE_CENTS) +
          (band_three_count * BAND_THREE_UNIT_FEE_CENTS)
      )
    end

    def self.unit_fee_for_position(position)
      return 0 if position <= INCLUDED_REGISTRATIONS
      return BAND_ONE_UNIT_FEE_CENTS if position <= BAND_ONE_LIMIT
      return BAND_TWO_UNIT_FEE_CENTS if position <= BAND_TWO_LIMIT

      BAND_THREE_UNIT_FEE_CENTS
    end
  end
end
