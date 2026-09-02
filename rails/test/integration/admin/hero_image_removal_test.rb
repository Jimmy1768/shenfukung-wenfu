# frozen_string_literal: true

require "test_helper"

class Admin::HeroImageRemovalTest < ActionDispatch::IntegrationTest
  setup do
    @temple = create_temple
    @owner = create_admin_user(temple: @temple, role: "owner", permission_overrides: { manage_profile: true })
    @temple.update!(hero_images: {
      "home" => "https://cdn.example/home.jpg",
      "events" => "https://cdn.example/events.jpg"
    })
    @asset = @temple.media_assets.create!(
      role: :hero_image,
      file_uid: "temples/#{@temple.id}/hero/events.jpg",
      metadata: { "hero_tab" => "events", "url" => "https://cdn.example/events-upload.jpg" }
    )
    sign_in_admin(@owner)
  end

  # The rendered form posts a url field for every tab, so a realistic payload
  # carries them all. A partial hash replaces the whole map.
  def submitted_hero_images(overrides = {})
    Temple::HERO_TABS.index_with { |tab| @temple.hero_images[tab].to_s }.merge(overrides)
  end

  test "ticking remove clears the tab through the profile form" do
    patch admin_temple_profile_path, params: {
      temple: { name: @temple.name, hero_images: submitted_hero_images },
      hero_image_remove: { "events" => "1" }
    }
    assert_redirected_to admin_temple_profile_path

    @temple.reload
    assert_equal "https://cdn.example/home.jpg", @temple.hero_image_for("events")
    assert_nil @temple.hero_media_asset_for("events")
    # The submitted paste-url value must not write the old image straight back.
    refute_equal "https://cdn.example/events.jpg", @temple.hero_images["events"]
  end

  # Removal runs before upload precisely so a replace-in-one-save ends with the
  # new image rather than the inherited one. S3 is stubbed the same way
  # hero_image_uploader_test does it.
  test "removing and uploading in the same save keeps the new image" do
    file = Rack::Test::UploadedFile.new(
      Rails.root.join("test/fixtures/files/sample_hero.png"), "image/png"
    )
    upload = ->(io:, key:, content_type:) { key }
    public_url = ->(key) { "https://cdn.example/#{key}" }

    Storage::S3Service.stub(:upload, upload) do
      Storage::S3Service.stub(:public_url, public_url) do
        patch admin_temple_profile_path, params: {
          temple: { name: @temple.name, hero_images: submitted_hero_images },
          hero_image_remove: { "events" => "1" },
          hero_image_upload: { "events" => file }
        }
      end
    end

    @temple.reload
    resolved = @temple.hero_image_for("events")
    refute_equal "https://cdn.example/home.jpg", resolved,
      "a same-save replace must end with the new image, not the inherited one"
    assert_match %r{uploads/hero-images/}, resolved
  end

  test "not ticking remove leaves the image alone" do
    patch admin_temple_profile_path, params: {
      temple: { name: @temple.name, hero_images: submitted_hero_images }
    }

    @temple.reload
    assert_equal "https://cdn.example/events.jpg", @temple.hero_image_for("events")
    refute_nil @temple.hero_media_asset_for("events")
  end

  test "the removal is audited, naming the tab and the retained file" do
    assert_difference -> { SystemAuditLog.where(action: "admin.temple_profile.hero_image_removed").count }, 1 do
      patch admin_temple_profile_path, params: {
        temple: { name: @temple.name, hero_images: submitted_hero_images },
        hero_image_remove: { "events" => "1" }
      }
    end

    entry = SystemAuditLog.where(action: "admin.temple_profile.hero_image_removed").last
    assert_equal "events", entry.metadata["hero_tab"]
    assert_equal @asset.file_uid, entry.metadata["file_uid"]
  end
end
