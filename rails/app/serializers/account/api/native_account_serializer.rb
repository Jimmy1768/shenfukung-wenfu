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

      # `delinquent:` is required rather than defaulted: forgetting it would
      # report :awaiting_payment for a temple whose settlement is frozen,
      # i.e. prompt the patron to pay when no payment can succeed. That is
      # the one wrong answer here, so callers must state it.
      #
      # `lifecycle` (fulfillment_status) is kept alongside lifecycle_stage
      # for the shipped build that already reads it. Additive only.
      #
      # Deliberately no `checkout_ready` field: lifecycle_stage already
      # subsumes it (:awaiting_admin_completion is exactly !checkout_ready?),
      # and native_account_contract_test asserts this payload carries no
      # "checkout" or "provider_reference" surface at all.
      def self.registration(registration, delinquent:)
        RegistrationSerializer.new(registration).as_json.merge(
          id: registration.id,
          lifecycle: registration.fulfillment_status,
          lifecycle_stage: registration.lifecycle_stage(delinquent: delinquent),
          payment_state: registration.payment_status
        )
      end

      def self.temple(temple)
        { slug: temple.slug, name: temple.name }
      end
    end
  end
end
