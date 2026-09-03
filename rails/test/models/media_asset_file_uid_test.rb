# frozen_string_literal: true

require "test_helper"

class MediaAssetFileUidTest < ActiveSupport::TestCase
  setup do
    @temple = create_temple(slug: "media-asset-uid", name: "UID")
  end

  test "file_uid must be a storage key, not a URL" do
    asset = MediaAsset.new(temple: @temple, role: :hero_image,
                           file_uid: "https://placehold.co/1600x900.png")

    refute asset.valid?
    assert_includes asset.errors[:file_uid], "must be a storage key, not a URL"
  end

  test "a real storage key is accepted" do
    asset = MediaAsset.new(temple: @temple, role: :hero_image,
                           file_uid: "uploads/hero-images/media-asset-uid/home/abc.jpg")

    assert asset.valid?, asset.errors.full_messages.to_sentence
  end

  test "the prefixed form of a storage key is accepted too" do
    asset = MediaAsset.new(temple: @temple, role: :hero_image,
                           file_uid: "prod/uploads/hero-images/media-asset-uid/home/abc.jpg")

    assert asset.valid?, asset.errors.full_messages.to_sentence
  end
end
