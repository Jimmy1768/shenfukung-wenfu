# frozen_string_literal: true

require "test_helper"

# The admin console promises "未填寫的頁面會使用「首頁」圖片" -- unfilled tabs
# inherit the home image. That was false wherever a seeded placehold.co media
# asset sat in front of the fallback, because the media-asset branch returned
# its URL unsanitized while the map branch filtered placeholders.
class TempleHeroImageFallbackTest < ActiveSupport::TestCase
  setup do
    @temple = Temple.find_by(slug: "shengfukung-wenfu") ||
              Temple.create!(slug: "shengfukung-wenfu", name: "示範宮廟")
  end

  test "every tab inherits the home image when only home is uploaded" do
    @temple.update!(hero_images: { "home" => "https://cdn.example/home.jpg" })

    Temple::HERO_TABS.each do |tab|
      assert_equal "https://cdn.example/home.jpg", @temple.hero_image_for(tab),
        "#{tab} should inherit the home image"
    end
  end

  test "a tab with its own image keeps it" do
    @temple.update!(hero_images: {
      "home" => "https://cdn.example/home.jpg",
      "archive" => "https://cdn.example/archive.jpg"
    })

    assert_equal "https://cdn.example/archive.jpg", @temple.hero_image_for("archive")
    assert_equal "https://cdn.example/home.jpg", @temple.hero_image_for("news")
  end

  test "the tab order matches the public site navigation" do
    # vue/src/components/site/SiteHeader.vue navItems, with `event` -- the
    # /events/:slug detail page, which has a hero but is not a nav item --
    # placed directly after the list it belongs to.
    assert_equal %w[home about news services events event archive contact], Temple::HERO_TABS
  end
end
