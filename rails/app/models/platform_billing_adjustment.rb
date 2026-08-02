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
  validates :platform_billing_usage_record_id, uniqueness: { scope: :platform_billing_statement_id }
end
