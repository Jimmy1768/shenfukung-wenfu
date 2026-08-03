# frozen_string_literal: true

class PlatformBillingDelivery < ApplicationRecord
  KINDS = %w[setup monthly].freeze
  STATUSES = %w[pending collecting paid overdue grace frozen].freeze

  belongs_to :temple
  belongs_to :platform_billing_statement, optional: true
  has_many :platform_billing_events, dependent: :restrict_with_exception

  scope :monthly, -> { where(kind: "monthly") }
  validates :kind, inclusion: { in: KINDS }
  validates :status, inclusion: { in: STATUSES }
  validates :currency, :idempotency_key, presence: true
  validates :platform_billing_statement_id, uniqueness: true, allow_nil: true
  validates :idempotency_key, uniqueness: true

  def paid? = status == "paid"
  def overdue? = %w[overdue grace frozen].include?(status)
end
