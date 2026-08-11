# frozen_string_literal: true

class RefreshToken < ApplicationRecord
  belongs_to :user

  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :active, -> { where(revoked: false).where("expires_at > ?", Time.current) }

  def active?
    !revoked? && expires_at.present? && expires_at > Time.current
  end
end
