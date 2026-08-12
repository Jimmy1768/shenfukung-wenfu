# frozen_string_literal: true

module Account
  module Api
    class RegistrationSerializer
      def initialize(registration)
        @registration = registration
      end

      def as_json(*)
        {
          reference_code: registration.reference_code,
          offering: offering_payload,
          quantity: registration.quantity,
          registrant_name: registrant_name,
          registrant_scope: registration.metadata.to_h["registrant_scope"].presence || "self",
          dependent_id: registration.metadata.to_h["dependent_id"].presence,
          contact_name: registration.contact_payload.to_h["primary_contact"],
          contact_phone: registration.contact_payload.to_h["phone"],
          contact_email: registration.contact_payload.to_h["email"],
          household_notes: registration.contact_payload.to_h["dependents_notes"],
          arrival_window: registration.logistics_payload.to_h["arrival_window"],
          ceremony_notes: registration.metadata.to_h["ceremony_notes"],
          total_amount_cents: registration.total_price_cents,
          unit_price_cents: registration.unit_price_cents,
          currency: registration.currency,
          payment_status: registration.payment_status,
          fulfillment_status: registration.fulfillment_status,
          certificate_number: registration.certificate_number,
          created_at: registration.created_at.iso8601
        }
      end

      private

      attr_reader :registration

      def offering_payload
        return {} unless registration.offering

        {
          id: registration.offering.id,
          title: registration.offering.title,
          period: registration.offering.try(:period) || registration.offering.try(:period_label),
          slug: registration.offering.slug,
          account_action: account_action_for(registration.offering),
          price_cents: registration.unit_price_cents,
          currency: registration.currency
        }
      end

      def account_action_for(offering)
        case offering
        when TempleService then "service"
        when TempleGathering then "gathering"
        else "event"
        end
      end

      def registrant_name
        registration.metadata.to_h["registrant_name"].presence || registration.contact_payload.to_h["primary_contact"].presence
      end
    end
  end
end
