# frozen_string_literal: true

class MediaAsset < ApplicationRecord
  belongs_to :temple

  enum :role, {
    hero_image: "hero_image",
    gathering_hero: "gathering_hero",
    gallery_image: "gallery_image",
    gallery_video: "gallery_video",
    attachment: "attachment"
  }

  scope :hero, -> { where(role: :hero_image) }

  validates :file_uid, presence: true
  validate :file_uid_is_a_storage_key


  def url
    metadata.fetch("url", nil)
  end

  private

  # file_uid is the S3 key returned by Storage::S3Service.upload, always. Rows
  # that carried a full URL here -- seeds used to create them for images it had
  # never uploaded -- broke the Phase 0 prefix migration, which would have
  # rewritten them to "prod/https://placehold.co/...". Enforced rather than
  # assumed, so that class of bug cannot come back.
  def file_uid_is_a_storage_key
    return if file_uid.blank?
    return unless file_uid.to_s.start_with?("http://", "https://")

    errors.add(:file_uid, "must be a storage key, not a URL")
  end
end
