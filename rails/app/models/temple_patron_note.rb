# frozen_string_literal: true

# Staff-authored service context about a patron: "returning donor, greets by
# name", "prefers Mandarin", "always brings elderly mother".
#
# This is the THIRD kind of note in the system and must not be confused with
# either of the others:
#
#   - the patron's own profile notes -- REMOVED 2026-08-31. It was scaffold
#     residue: a bare "Notes" textarea with no stated purpose that staff code
#     then read as contact detail.
#   - Registrations::UserMetadataUpdater::NAMESPACE notes -- contact detail
#     captured against a registration ("seat near exit"), reused to prefill
#     the next one. About a booking, not about a person.
#
# Two properties this type exists to guarantee:
#
#   1. NEVER patron-visible. It is not serialized by any account or native
#      endpoint, and there is no patron-facing read path to it.
#   2. Temple-scoped. A User is global across tenants, so one patron may be
#      known to several temples; each keeps its own note and cannot see
#      another's.
class TemplePatronNote < ApplicationRecord
  MAX_LENGTH = 4_000

  belongs_to :temple
  belongs_to :user
  belongs_to :updated_by_admin_account, class_name: "AdminAccount", optional: true

  validates :body, length: { maximum: MAX_LENGTH }
  validates :user_id, uniqueness: { scope: :temple_id }

  scope :for, ->(temple:, user:) { find_by(temple:, user:) }

  def self.upsert_body!(temple:, user:, body:, admin_account: nil)
    note = find_or_initialize_by(temple:, user:)
    note.body = body.to_s
    note.updated_by_admin_account = admin_account
    note.save!
    note
  end

  def blank_body? = body.to_s.strip.empty?
end
