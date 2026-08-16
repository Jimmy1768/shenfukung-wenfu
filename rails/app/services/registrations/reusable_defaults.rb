# frozen_string_literal: true

module Registrations
  # Owns the only safe storage boundary for per-offering registration defaults.
  # Legacy metadata["offerings"] is deliberately neither read nor written here.
  class ReusableDefaults
    NAMESPACE = "registration_reusable_defaults_v1"
    TRANSIENT_KEY_PATTERN = /(date|time)\z/i
    REGISTRABLE_TYPES = %w[TempleEvent TempleService TempleGathering].freeze
    FORBIDDEN_FIELDS = %w[
      quantity unit_price_cents total_price_cents total_amount_cents currency certificate_number
      event_slug offering_slug registrable_id registrable_type registration_period_key
      registrant_scope dependent_id registrant_name payment_status refund_status cancellation_status
      fulfillment_status reference_code expires_at identity authority privacy closure
    ].freeze

    def initialize(user:, temple:, offering:)
      @user = user
      @temple = temple
      @offering = offering
      @schema = FormSchema.new(offering&.metadata&.fetch("registration_form", nil))
    end

    def read
      scoped_data.deep_dup
    end

    def write!(values)
      persist do |data|
        eligible_values(values).each do |field, value|
          if multi_value?(field)
            data[field] = (Array(data[field]) + Array(value)).map(&:to_s).reject(&:blank?).uniq
          else
            data[field] = value
          end
        end
      end
    end

    def add!(field:, value:)
      field = eligible_field!(field)
      raise ArgumentError, "Field does not allow multiple values" unless multi_value?(field)
      raise ArgumentError, "Value can't be blank" if value.blank?

      persist do |data|
        data[field] = (Array(data[field]) + [value.to_s]).reject(&:blank?).uniq
      end
    end

    def clear!(field:, value: nil)
      field = eligible_field!(field)
      persist do |data|
        if multi_value?(field)
          raise ArgumentError, "Value can't be blank" if value.blank?

          data[field] = Array(data[field]).reject(&:blank?).reject { |entry| entry == value.to_s }
          data.delete(field) if data[field].empty?
        else
          raise ArgumentError, "Scalar fields do not accept a value" if value.present?

          data.delete(field)
        end
      end
    end

    def eligible_field?(field)
      eligible_fields.include?(field.to_s)
    end

    private

    attr_reader :user, :temple, :offering, :schema

    def persist
      return {} unless valid_context?

      metadata = (user.metadata || {}).deep_dup
      data = scoped_data_from(metadata)
      yield data
      write_scoped_data(metadata, data)
      user.update!(metadata: metadata) if metadata != (user.metadata || {})
      data.deep_dup
    end

    def scoped_data
      return {} unless valid_context?

      scoped_data_from(user.metadata || {}).deep_dup
    end

    def scoped_data_from(metadata)
      metadata.dig(NAMESPACE, temple.id.to_s, registrable_type, offering.id.to_s).to_h
    end

    def write_scoped_data(metadata, data)
      root = metadata[NAMESPACE] ||= {}
      temple_data = root[temple.id.to_s] ||= {}
      type_data = temple_data[registrable_type] ||= {}
      if data.empty?
        type_data.delete(offering.id.to_s)
      else
        type_data[offering.id.to_s] = data
      end
    end

    def valid_context?
      user.present? && temple.present? && offering.present? && offering.temple_id == temple.id && REGISTRABLE_TYPES.include?(registrable_type)
    end

    def registrable_type
      offering.class.base_class.name
    end

    def eligible_values(values)
      values.to_h.each_with_object({}) do |(field, value), result|
        field = field.to_s
        next unless eligible_field?(field)
        next if value.blank?
        next if value.is_a?(Array) && !multi_value?(field)

        result[field] = value
      end
    end

    def eligible_field!(field)
      field = field.to_s
      raise ArgumentError, "Field is not reusable for this offering" unless eligible_field?(field)

      field
    end

    def eligible_fields
      @eligible_fields ||= (%i[logistics ritual_metadata].flat_map { |section| schema.fields_for(section) })
        .map(&:to_s)
        .reject { |field| field.match?(TRANSIENT_KEY_PATTERN) }
        .reject { |field| FORBIDDEN_FIELDS.include?(field) }
        .uniq
    end

    def multi_value?(field)
      schema.allow_multiple?(field)
    end
  end
end
