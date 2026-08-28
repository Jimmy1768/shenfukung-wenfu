# frozen_string_literal: true

require "action_view"

module Currency
  module Symbols
    extend self
    include ActionView::Helpers::NumberHelper

    MAP = {
      "TWD" => "NT$",
      "USD" => "$",
      "EUR" => "€",
      "JPY" => "¥"
    }.freeze

    PRECISION = Hash.new(2).merge(
      "TWD" => 0,
      "JPY" => 0
    ).freeze

    def symbol_for(code)
      return "" if code.blank?

      MAP[code.to_s.upcase] || code.to_s.upcase
    end

    def options
      MAP.map { |code, symbol| ["#{symbol} (#{code})", code] }
    end

    def precision_for(code)
      PRECISION[code.to_s.upcase]
    end

    def zero_decimal_currency?(code)
      precision_for(code).zero?
    end

    def admin_input_to_amount_cents(value, code)
      return nil if value.nil?
      return 0 if value.respond_to?(:blank?) && value.blank?

      numeric = value.to_i
      zero_decimal_currency?(code) ? numeric * 100 : numeric
    end

    def admin_input_value(amount_cents, code)
      return nil if amount_cents.nil?

      zero_decimal_currency?(code) ? (amount_cents.to_i / 100) : amount_cents
    end

    def format_amount(amount_cents, code)
      amount = amount_cents.to_f / 100.0
      number_to_currency(
        amount,
        unit: symbol_for(code),
        precision: precision_for(code)
      )
    end

    # For a per-unit rate (e.g. a price per registration), not a total.
    # format_amount's precision_for(code) is correct for invoice totals
    # (TWD/JPY round to whole units there), but a per-unit rate can be a
    # fraction of that currency's normal display precision -- TWD's
    # tiered platform pricing is NT$1.00/1.25/1.50 per registration, and
    # rounding those to the nearest whole dollar would show the same
    # "NT$1" for two genuinely different rates and overstate the third
    # by 33%. Always shows at least 2 decimal places regardless of the
    # currency's own invoice-rounding convention.
    def format_unit_rate(amount_cents, code)
      amount = amount_cents.to_f / 100.0
      number_to_currency(
        amount,
        unit: symbol_for(code),
        precision: [precision_for(code), 2].max
      )
    end

    alias_method :for, :symbol_for
  end
end
