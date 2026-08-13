# frozen_string_literal: true

module Payments
  module Taiwan
    # ECPay's TotalAmount and TradeAmt fields are positive whole TWD values,
    # while Wenfu retains all payment amounts in minor units.
    class EcpayAmount
      MINOR_UNITS_PER_TWD = 100
      InvalidAmount = Class.new(ArgumentError)
      InvalidCurrency = Class.new(ArgumentError)

      def self.to_wire!(amount_cents:, currency:)
        assert_twd!(currency)
        amount = Integer(amount_cents)
        raise InvalidAmount, "ECPay amount must be positive" unless amount.positive?
        raise InvalidAmount, "ECPay amount must be whole TWD" unless (amount % MINOR_UNITS_PER_TWD).zero?

        (amount / MINOR_UNITS_PER_TWD).to_s
      rescue TypeError, ArgumentError => error
        raise error if error.is_a?(InvalidAmount) || error.is_a?(InvalidCurrency)

        raise InvalidAmount, "ECPay amount must be a positive whole TWD value"
      end

      def self.from_wire!(amount:, currency: "TWD")
        assert_twd!(currency)
        value = amount.to_s
        raise InvalidAmount, "ECPay TradeAmt must be a positive integer" unless value.match?(/\A[1-9]\d*\z/)

        Integer(value) * MINOR_UNITS_PER_TWD
      end

      def self.assert_twd!(currency)
        return if currency.to_s.upcase == "TWD"

        raise InvalidCurrency, "ECPay only accepts TWD"
      end
      private_class_method :assert_twd!
    end
  end
end
