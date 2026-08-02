class PlatformBillingUsageRecord < ApplicationRecord
  belongs_to :platform_billing_statement
  belongs_to :temple
  belongs_to :temple_registration

  validates :registration_created_at, presence: true
  validates :unit_fee_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :temple_registration_id, uniqueness: { scope: :platform_billing_statement_id }
end
