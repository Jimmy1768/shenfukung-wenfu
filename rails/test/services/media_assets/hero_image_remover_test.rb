# frozen_string_literal: true

require "test_helper"

# A hero tab has two storage paths -- temple.hero_images[tab] and a MediaAsset
# carrying metadata["hero_tab"] -- and the admin only ever exposed the first.
# Clearing the URL box left the uploaded asset still winning in
# Temple#hero_image_for, so an image could be replaced but never removed.
class MediaAssets::HeroImageRemoverTest < ActiveSupport::TestCase
  setup do
    @temple = create_temple
    @temple.update!(hero_images: {
      "home" => "https://cdn.example/home.jpg",
      "events" => "https://cdn.example/events.jpg"
    })
  end

  def upload_asset_for(tab, url)
    @temple.media_assets.create!(
      role: :hero_image,
      file_uid: "temples/#{@temple.id}/hero/#{tab}.jpg",
      metadata: { "hero_tab" => tab, "url" => url }
    )
  end

  test "clears both storage paths so the tab inherits the home image" do
    upload_asset_for("events", "https://cdn.example/events-upload.jpg")
    assert_equal "https://cdn.example/events.jpg", @temple.hero_image_for("events")

    MediaAssets::HeroImageRemover.call(temple: @temple, hero_tab: "events")
    @temple.reload

    assert_equal "https://cdn.example/home.jpg", @temple.hero_image_for("events"),
      "the tab must fall back to home, not keep the unlinked asset"
    refute @temple.hero_images.key?("events")
    assert_nil @temple.hero_media_asset_for("events")
  end

  test "clearing only the url would not have been enough -- the asset is unlinked too" do
    asset = upload_asset_for("events", "https://cdn.example/events-upload.jpg")

    # Simulate the old workaround: blank the paste-url box only.
    @temple.update!(hero_images: @temple.hero_images.merge("events" => ""))
    assert_equal "https://cdn.example/events-upload.jpg", @temple.reload.hero_image_for("events"),
      "precondition: the asset still wins, which is the bug"

    MediaAssets::HeroImageRemover.call(temple: @temple, hero_tab: "events")
    assert_equal "https://cdn.example/home.jpg", @temple.reload.hero_image_for("events")
    refute_nil asset.reload, "the row must survive -- unlink, not delete"
  end

  test "the MediaAsset row and its file are kept, only the binding goes" do
    asset = upload_asset_for("events", "https://cdn.example/events-upload.jpg")
    key = asset.file_uid

    MediaAssets::HeroImageRemover.call(temple: @temple, hero_tab: "events")
    asset.reload

    assert_equal key, asset.file_uid, "the stored object reference must survive for orphan reclamation"
    assert_equal "https://cdn.example/events-upload.jpg", asset.metadata["url"]
    assert_nil asset.metadata["hero_tab"], "the tab binding is what gets cleared"
    assert_equal "events", asset.metadata["unlinked_from_tab"]
    assert asset.metadata["unlinked_at"].present?
  end

  test "the home image cannot be removed -- it is the root of the fallback chain" do
    error = assert_raises(MediaAssets::HeroImageRemover::RemovalError) do
      MediaAssets::HeroImageRemover.call(temple: @temple, hero_tab: "home")
    end
    assert_match(/cannot be removed/, error.message)

    # Untouched: every other tab still has something to inherit.
    assert_equal "https://cdn.example/home.jpg", @temple.reload.hero_image_for("home")
    assert_equal "https://cdn.example/home.jpg", @temple.hero_image_for("archive")
  end

  test "removing a tab that has no image is a no-op" do
    result = MediaAssets::HeroImageRemover.call(temple: @temple, hero_tab: "archive")

    assert_equal false, result[:removed]
    assert_equal "https://cdn.example/home.jpg", @temple.reload.hero_image_for("archive")
  end

  test "an unknown tab is rejected" do
    assert_raises(MediaAssets::HeroImageRemover::RemovalError) do
      MediaAssets::HeroImageRemover.call(temple: @temple, hero_tab: "not_a_tab")
    end
  end
end
