class PlatformBillingStatement < ApplicationRecord
  STATUSES = %w[closed].freeze

  belongs_to :temple
  has_many :platform_billing_usage_records, dependent: :restrict_with_exception
  has_many :platform_billing_adjustments, dependent: :restrict_with_exception
  has_one :platform_billing_delivery, dependent: :restrict_with_exception

  validates :status, inclusion: { in: STATUSES }
  validates :pricing_policy_version, :currency, :idempotency_key, :period_start_at,
    :period_end_at, :closed_at, presence: true
  validates :period_start_at, uniqueness: { scope: :temple_id }
  validates :registration_count, :included_registration_count,
    :band_one_registration_count, :band_two_registration_count,
    :band_three_registration_count, numericality: { greater_than_or_equal_to: 0 }
  validates :base_fee_cents, :band_one_fee_cents, :band_two_fee_cents,
    :band_three_fee_cents, :usage_total_cents, :total_cents,
    numericality: { greater_than_or_equal_to: 0 }

  def refresh_adjustment_total!
    update!(
      adjustment_total_cents: platform_billing_adjustments.sum(:amount_cents),
      total_cents: usage_total_cents + platform_billing_adjustments.sum(:amount_cents)
    )
  end
end
