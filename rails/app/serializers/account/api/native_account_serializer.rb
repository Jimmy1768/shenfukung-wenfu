# frozen_string_literal: true

module Account
  module Api
    class NativeAccountSerializer
      def self.user(user)
        metadata = user.metadata.to_h
        {
          id: user.id,
          email: user.email,
          english_name: user.english_name,
          native_name: user.native_name,
          phone: metadata["phone"],
          city: metadata["city"],
          notes: metadata["notes"]
        }.compact
      end

      def self.dependent(link)
        dependent = link.dependent
        metadata = dependent.metadata.to_h
        {
          id: link.id,
          dependent_id: dependent.id,
          english_name: dependent.english_name,
          native_name: dependent.native_name,
          relationship_label: link.relationship_label || dependent.relationship_label,
          birthdate: dependent.birthdate,
          phone: metadata["phone"],
          email: metadata["email"],
          notes: metadata["notes"]
        }.compact
      end

      def self.registration(registration)
        RegistrationSerializer.new(registration).as_json.merge(
          id: registration.id,
          lifecycle: registration.fulfillment_status,
          payment_state: registration.payment_status
        ).except(:total_amount_cents)
      end

      def self.temple(temple)
        { slug: temple.slug, name: temple.name }
      end
    end
  end
end
