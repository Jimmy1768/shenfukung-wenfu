# frozen_string_literal: true

module Registrations
  class UserMetadataUpdater
    CONTACT_MAPPINGS = {
      "phone" => "phone",
      "dependents_notes" => "notes",
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
      CONTACT_MAPPINGS.each do |source, destination|
        value = contact_payload[source] || contact_payload[source.to_sym]
        next if value.blank?

        assign_value(metadata, destination, value)
      end
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

    def assign_value(container, key, value)
      key = key.to_s
      container[key] = value
    end
  end
end
