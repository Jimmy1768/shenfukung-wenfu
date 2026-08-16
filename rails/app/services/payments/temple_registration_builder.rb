# frozen_string_literal: true

module Payments
  class TempleRegistrationBuilder
    def initialize(temple:, offering:, admin_user:, attributes:)
      @temple = temple
      @offering = offering
      @admin_user = admin_user
      @attributes = attributes.to_h.deep_symbolize_keys
    end

    def create
      TempleRegistration.transaction do
        registration = temple.temple_registrations.new(registration_attributes)
        registration.registrable ||= offering
        registration.event_slug ||= offering.slug
        registration.save!

        persist_user_defaults(registration)

        SystemAuditLogger.log!(
          action: "temple.registration.create",
          admin: admin_user,
          target: registration,
          metadata: {
            offering_id: offering.id,
            reference_code: registration.reference_code
          },
          temple:
        )

        registration
      end
    end

    private

    attr_reader :temple, :offering, :admin_user, :attributes

    def multi_value_fields
      @multi_value_fields ||= Array(@attributes.delete(:multi_value_fields)).map(&:to_s)
    end

    def registration_attributes
      {
        user_id: attributes[:user_id],
        quantity: attributes[:quantity].presence || 1,
        unit_price_cents: unit_price_cents,
        currency: attributes[:currency].presence || offering.currency,
        certificate_number: attributes[:certificate_number],
        event_slug: attributes[:event_slug].presence || offering.slug,
        contact_payload: attributes[:contact_payload].presence || {},
        logistics_payload: attributes[:logistics_payload].presence || {},
        metadata: merged_metadata
      }
    end

    def merged_metadata
      payload = attributes[:metadata].presence || {}
      key = resolved_registration_period_key
      payload = payload.merge("registration_period_key" => key) if key.present? && payload["registration_period_key"].blank?
      payload
    end

    def resolved_registration_period_key
      return unless offering.respond_to?(:registration_period_key)

      offering.registration_period_key.presence
    end

    def unit_price_cents
      value = attributes[:unit_price_cents]
      return offering.price_cents if value.blank? || value.to_i.zero?

      value.to_i
    end

    def persist_user_defaults(registration)
      user = registration.user
      return unless user

      Registrations::UserMetadataUpdater.new(
        user:,
        offering:,
        contact_payload: dependent_selected? ? {} : attributes[:contact_payload],
        logistics_payload: attributes[:logistics_payload],
        ritual_metadata: user_metadata_payload
      ).update!
      sync_dependent_profile!(user) if dependent_selected?
    end

    def user_metadata_payload
      payload = attributes[:metadata].presence || {}
      payload.except("registration_period_key", :registration_period_key)
    end

    def dependent_selected?
      attributes.dig(:metadata, :registrant_scope) == "dependent" || attributes.dig(:metadata, "registrant_scope") == "dependent"
    end

    def sync_dependent_profile!(user)
      dependent_id = attributes.dig(:metadata, :dependent_id) || attributes.dig(:metadata, "dependent_id")
      dependent = user.dependents.find_by(id: dependent_id)
      return unless dependent

      contact = attributes[:contact_payload].to_h
      payload = {
        "phone" => contact["phone"].presence || contact[:phone].presence,
        "email" => contact["email"].presence || contact[:email].presence,
        "notes" => contact["dependents_notes"].presence || contact[:dependents_notes].presence || contact["notes"].presence || contact[:notes].presence
      }.compact
      dependent.update!(metadata: (dependent.metadata || {}).merge(payload)) if payload.present?
    end
  end
end
