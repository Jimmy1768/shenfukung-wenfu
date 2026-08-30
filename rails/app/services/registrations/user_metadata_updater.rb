# frozen_string_literal: true

module Registrations
  class UserMetadataUpdater
    # Where a registration's contact answers are cached for future prefill.
    #
    # Deliberately NOT the patron's own profile keys (user.metadata["phone"],
    # ["notes"], ["city"]) -- those are owned by the patron and written only
    # by Account::ProfileForm. Before 2026-08-28 this class wrote straight
    # into them, so an admin completing a registration silently rewrote the
    # patron's stored profile with no recoverable prior value. A temple is
    # authoritative over "what number did we reach them at for this
    # registration"; it is not authoritative over "what is this person's
    # phone number."
    #
    # Readers that want the freshest known contact value use
    # ReusableContact.read, which prefers this namespace and falls back to
    # the profile. Readers showing the patron their OWN profile (ProfileForm,
    # NativeAccountSerializer.user) deliberately do not.
    NAMESPACE = "registration_contact"

    # "dependents_notes" is intentionally absent. It describes a selected
    # dependent, not the patron, and already has its own destination via
    # Registrations::DependentContactSync. Mapping it here alongside "notes"
    # also meant both wrote the same key, so whichever came second in hash
    # order silently discarded the other.
    CONTACT_MAPPINGS = {
      "phone" => "phone",
      "notes" => "notes"
    }.freeze

    def initialize(user:, offering:, contact_payload:, logistics_payload:, ritual_metadata:)
      @user = user
      @offering = offering
      @contact_payload = (contact_payload || {}).to_h
      @logistics_payload = (logistics_payload || {}).to_h
      @ritual_metadata = (ritual_metadata || {}).to_h
    end

    def update!
      return unless user

      metadata = (user.metadata || {}).deep_dup
      update_contact_metadata(metadata)
      user.update!(metadata: metadata) if metadata != (user.metadata || {})
      update_offering_metadata
    end

    private

    attr_reader :user, :offering, :contact_payload, :logistics_payload, :ritual_metadata

    def update_contact_metadata(metadata)
      scoped = (metadata[NAMESPACE] || {}).dup

      CONTACT_MAPPINGS.each do |source, destination|
        value = contact_payload[source] || contact_payload[source.to_sym]
        next if value.blank?

        scoped[destination.to_s] = value
      end

      metadata[NAMESPACE] = scoped if scoped.present?
    end

    def update_offering_metadata
      return if offering.blank?

      ReusableDefaults.new(user:, temple: offering.temple, offering:).write!(build_offering_payload)
    end

    def build_offering_payload
      payload = {}
      logistics_payload.each { |key, value| payload[key.to_s] = value }
      ritual_metadata.each { |key, value| payload[key.to_s] = value }
      payload.compact_blank
    end
  end
end
