# frozen_string_literal: true

module Registrations
  # Given a patron-selected dependent and phone/email/notes candidate values
  # sourced by the caller (form attributes, a persisted registration payload,
  # etc.), merges only the present values onto the dependent's own metadata.
  #
  # This is intentionally the only place that performs the merge-and-persist
  # step; callers remain responsible for sourcing their own raw phone/email/
  # notes values (that extraction legitimately differs per call site) and for
  # deciding whether a sync should happen at all (dependent selected, edit
  # lifecycle allows a reusable-data refresh, etc.).
  class DependentContactSync
    def self.call!(dependent:, phone: nil, email: nil, notes: nil)
      new(dependent:, phone:, email:, notes:).call!
    end

    def initialize(dependent:, phone: nil, email: nil, notes: nil)
      @dependent = dependent
      @phone = phone
      @email = email
      @notes = notes
    end

    def call!
      return unless dependent

      payload = contact_payload
      return if payload.blank?

      updated_metadata = (dependent.metadata || {}).merge(payload)
      return if updated_metadata == (dependent.metadata || {})

      dependent.update!(metadata: updated_metadata)
    end

    private

    attr_reader :dependent, :phone, :email, :notes

    def contact_payload
      {
        "phone" => phone.presence,
        "email" => email.presence,
        "notes" => notes.presence
      }.compact
    end
  end
end
