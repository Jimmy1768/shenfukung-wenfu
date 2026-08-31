# frozen_string_literal: true

module Registrations
  # Read side of the registration-contact split introduced 2026-08-28.
  #
  # A registration's contact answers are cached under
  # UserMetadataUpdater::NAMESPACE rather than in the patron's own profile
  # fields, so staff can never silently rewrite patron-owned data. That split
  # would break the "don't make an admin ask the same question again" rule on
  # its own, because prefill previously read the profile. Precedence restores
  # it: the most recently captured registration value wins, and the patron's
  # own profile is the fallback.
  #
  # Use this for PREFILL and for staff-facing "how do we reach them" views.
  # Do not use it where the patron is being shown their own profile -- there,
  # the profile is the answer by definition.
  class ReusableContact
    FIELDS = %w[phone notes].freeze

    # Only fields the patron still owns on their own profile can fall back to
    # it. `notes` was removed from the profile on 2026-08-31 -- it was scaffold
    # residue (a bare "Notes" textarea with no stated purpose) that staff code
    # then read as contact detail. Old values may still sit in top-level
    # metadata; they are deliberately not surfaced, because presenting
    # arbitrary patron text as "how do we reach them" is the confusion that
    # removal was meant to end. Registration-captured notes still work, since
    # those are written into the namespaced scope.
    PROFILE_FALLBACK_FIELDS = %w[phone].freeze

    def self.read(user, field)
      new(user).read(field)
    end

    def initialize(user)
      @metadata = (user&.metadata || {}).to_h
    end

    def read(field)
      field = field.to_s
      return nil unless FIELDS.include?(field)
      return scoped[field].presence unless PROFILE_FALLBACK_FIELDS.include?(field)

      scoped[field].presence || @metadata[field].presence
    end

    private

    def scoped
      @scoped ||= (@metadata[UserMetadataUpdater::NAMESPACE] || {}).to_h
    end
  end
end
