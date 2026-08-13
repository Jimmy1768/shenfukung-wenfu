class PlatformBillingAdjustment < ApplicationRecord
  REASONS = %w[cancelled failed refunded].freeze

  belongs_to :platform_billing_statement
  belongs_to :source_platform_billing_statement, class_name: "PlatformBillingStatement"
  belongs_to :platform_billing_usage_record
  belongs_to :temple
  belongs_to :temple_registration

  validates :reason, inclusion: { in: REASONS }
  validates :recognized_at, presence: true
  validates :registration_count_delta, numericality: { less_than: 0 }
  validates :amount_cents, numericality: { less_than_or_equal_to: 0 }
  validates :platform_billing_usage_record_id, uniqueness: true
  validate :tenant_matches_related_records

  private

  def tenant_matches_related_records
    related_temples = [
      platform_billing_statement&.temple_id,
      source_platform_billing_statement&.temple_id,
      platform_billing_usage_record&.temple_id,
      temple_registration&.temple_id
    ].compact
    return if related_temples.all? { |related_temple_id| related_temple_id == temple_id }

    errors.add(:temple, "must match the statement, usage record, and registration temple")
  end
end
