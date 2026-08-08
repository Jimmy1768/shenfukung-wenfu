# frozen_string_literal: true

class PlatformBillingEntitlement < ApplicationRecord
  STATES = %w[pending_setup active suspended].freeze

  belongs_to :temple
  belongs_to :platform_billing_delivery, optional: true
  belongs_to :platform_billing_event, optional: true

  validates :state, inclusion: { in: STATES }
  validates :temple_id, uniqueness: true
  validates :adopted_at, :transitioned_at, presence: true

  def active?
    state == "active"
  end
end
