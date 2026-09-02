# frozen_string_literal: true

require "test_helper"
require Rails.root.join("db/seeds/temples")

# On 2026-09-01 a routine `rails db:seed` on production -- run to apply a
# temple rename -- wiped the demo temple's uploaded hero images back to
# DEFAULT_HERO_IMAGE, because the seed assigned every profile field
# unconditionally from a yml that leaves them blank. Every field it touches is
# also editable in the admin console (Admin::TempleProfileForm).
class TempleSeedPreservesAdminContentTest < ActiveSupport::TestCase
  test "re-seeding applies the yml but never blanks admin-owned content" do
    temple = Temple.find_by(slug: "shengfukung-wenfu") ||
             Temple.create!(slug: "shengfukung-wenfu", name: "placeholder")

    temple.update!(
      name: "STALE NAME",
      hero_images: { "home" => "https://cdn.example/uploaded-hero.jpg" },
      primary_image_url: "https://cdn.example/uploaded-primary.jpg",
      about_html: "<p>admin wrote this</p>"
    )

    Seeds::Temples.seed
    temple.reload

    # The yml supplies a name, so a rename still lands.
    assert_equal "示範宮廟", temple.name

    # It supplies none of these, so the admin's work survives.
    assert_equal({ "home" => "https://cdn.example/uploaded-hero.jpg" }, temple.hero_images)
    assert_equal "https://cdn.example/uploaded-primary.jpg", temple.primary_image_url
    assert_equal "<p>admin wrote this</p>", temple.about_html
  end

  test "a brand new temple still receives the default hero images" do
    fresh = Temple.new(slug: "seed-fresh-temple", name: "Fresh")

    images = Seeds::Temples.send(:hero_images_for, fresh, {})

    assert_equal Temple::HERO_TABS.size, images.size
    assert images.values.all?(&:present?), "a new temple must not start with blank heroes"
  end
end
