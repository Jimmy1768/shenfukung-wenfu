class PlatformBillingUsageRecord < ApplicationRecord
  belongs_to :platform_billing_statement
  belongs_to :temple
  belongs_to :temple_registration

  validates :registration_created_at, presence: true
  validates :qualifying_at, :qualification_source, presence: true, on: :create
  validates :unit_fee_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :temple_registration_id, uniqueness: { scope: :temple_id }
  validate :tenant_matches_statement
  validate :tenant_matches_registration

  def qualifying_timestamp
    qualifying_at || registration_created_at
  end

  private

  def tenant_matches_statement
    return if platform_billing_statement.blank? || temple_id == platform_billing_statement.temple_id

    errors.add(:temple, "must match the platform billing statement temple")
  end

  def tenant_matches_registration
    return if temple_registration.blank? || temple_id == temple_registration.temple_id

    errors.add(:temple, "must match the registration temple")
  end
end
