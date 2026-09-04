# frozen_string_literal: true

# Ordering for the surfaces a patron browses: what they can still attend comes
# first. Ongoing and upcoming soonest-first, then finished most-recent-first.
#
# Plain chronological order buried a newly created event below events that had
# already ended, on every surface at once -- the account web, the native API and
# the admin each carried their own copy of the same ASC sort.
#
# The past test matches #timeline_status on both models, which is what the
# 已結束 badge renders from. Ordering and badge must not be able to disagree.
module PatronOrdered
  extend ActiveSupport::Concern

  included do
    scope :order_for_patrons, lambda {
      table = arel_table.name
      past = "(#{table}.ends_on IS NOT NULL AND #{table}.ends_on < CURRENT_DATE)"
      starts = "COALESCE(#{table}.starts_on, DATE(#{table}.created_at))"

      order(
        Arel.sql(
          "CASE WHEN #{past} THEN 1 ELSE 0 END ASC, " \
          "CASE WHEN #{past} THEN NULL ELSE #{starts} END ASC NULLS LAST, " \
          "CASE WHEN #{past} THEN #{starts} ELSE NULL END DESC NULLS LAST"
        )
      )
    }
  end
end
