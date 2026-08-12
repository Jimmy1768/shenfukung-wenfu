# frozen_string_literal: true

class OAuthAccountResolution < ApplicationRecord
  TTL = 10.minutes

  belongs_to :consumed_by_user, class_name: "User", optional: true

  validates :token_digest, :provider, :provider_uid, :surface, :expires_at, presence: true
  validates :token_digest, uniqueness: true
  validates :surface, inclusion: { in: %w[account native] }
  validates :purpose, inclusion: { in: %w[account_resolution consolidation] }
  validate :expiry_is_after_creation

  def expired?
    expires_at <= Time.current
  end

  def consumable?
    consumed_at.blank? && !expired?
  end

  private

  def expiry_is_after_creation
    return if expires_at.blank? || created_at.blank? || expires_at > created_at

    errors.add(:expires_at, "must be after creation")
  end
end
