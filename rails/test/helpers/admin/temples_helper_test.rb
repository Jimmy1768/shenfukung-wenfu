# frozen_string_literal: true

require "test_helper"

module Admin
  class TemplesHelperTest < ActionView::TestCase
    tests Admin::TemplesHelper

    setup do
      @temple = create_temple(slug: "hero-preview", name: "Preview")
      @temple.update!(hero_images: { "home" => "https://cdn.example/home.jpg" })
      @form = Admin::TempleProfileForm.new(temple: @temple)
    end

    test "a tab with its own image previews that image" do
      @temple.update!(hero_images: @temple.hero_images.merge("about" => "https://cdn.example/about.jpg"))
      form = Admin::TempleProfileForm.new(temple: @temple.reload)

      assert_equal "https://cdn.example/about.jpg", hero_image_preview_for(form, "about")
    end

    # Regressed once, silently: the admin used to get the placeholder because
    # the seed persisted one in every unset tab, and when that stopped the
    # preview started showing the inherited image instead. An empty slot that
    # looks filled is a false positive for the admin.
    test "a tab that inherits the home image previews the placeholder, not the inherited image" do
      preview = hero_image_preview_for(@form, "about")

      assert_equal Admin::TemplesHelper::PLACEHOLDER_ASSET, preview
      refute_equal @temple.hero_image_for("about"), preview,
                   "the admin must not show what the public site resolves to"
    end

    test "the public site still resolves that tab to the home image" do
      assert_equal "https://cdn.example/home.jpg", @temple.hero_image_for("about")
    end

    test "hero_image_set_for? agrees with the preview" do
      refute hero_image_set_for?(@form, "about")
      assert hero_image_set_for?(@form, "home")
    end
  end
end
