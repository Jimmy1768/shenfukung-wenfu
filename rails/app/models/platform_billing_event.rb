# frozen_string_literal: true

class PlatformBillingEvent < ApplicationRecord
  belongs_to :temple
  belongs_to :platform_billing_delivery, optional: true
  validates :provider_event_id, presence: true, uniqueness: true
  validates :event_type, presence: true
end
