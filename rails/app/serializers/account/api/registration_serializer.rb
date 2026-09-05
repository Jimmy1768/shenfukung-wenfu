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
          # Both delegate to TempleRegistration, which owns the resolution.
          # This serializer used to carry its own partial copies: the name one
          # checked two of the model's six sources and returned nil when both
          # were blank (the app rendered "<title> · "), and the scope one always
          # fell back to "self", so a dependent registration whose metadata had
          # lost the key was reported as the account holder.
          registrant_name: registration.registrant_name,
          registrant_scope: registration.registrant_scope,
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
    end
  end
end
