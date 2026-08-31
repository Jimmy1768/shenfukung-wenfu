# frozen_string_literal: true

# A patron's join with a temple.
#
# Binding is the join gesture: scanning the temple QR in the app, or selecting
# the temple on the web, while signed in. Nothing else creates one -- notably
# not a registration. A registration is a *consequence* of having joined, and
# making it the join was backwards: it forced anyone who needed to be on a
# temple's list (staff of twenty years, for instance) to buy an offering first.
#
# Recorded on access rather than intent, so a patron who scans out of
# curiosity and never registers is still on that temple's radar -- which is the
# point: they can be invited back.
class TempleConnection < ApplicationRecord
  # Only touch last_seen_at this often; every authenticated request in a temple
  # context passes through here.
  SEEN_THROTTLE = 1.day

  belongs_to :temple
  belongs_to :user

  def self.record!(user:, temple:, now: Time.current)
    return nil if user.blank? || temple.blank?

    connection = find_by(user_id: user.id, temple_id: temple.id)
    if connection.nil?
      return create!(user:, temple:, first_connected_at: now, last_seen_at: now)
    end

    if connection.last_seen_at.nil? || connection.last_seen_at < now - SEEN_THROTTLE
      connection.update_columns(last_seen_at: now, updated_at: now)
    end
    connection
  rescue ActiveRecord::RecordNotUnique
    # Concurrent first request from the same patron; the row now exists.
    find_by(user_id: user.id, temple_id: temple.id)
  end
end
