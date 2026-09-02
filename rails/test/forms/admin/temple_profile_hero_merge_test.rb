# frozen_string_literal: true

require "test_helper"

# The form used to assign the submitted hero_images hash wholesale, so any
# caller posting a subset silently wiped the tabs it omitted. The rendered form
# happens to post a field for every tab, which is the only reason it never bit.
class Admin::TempleProfileHeroMergeTest < ActiveSupport::TestCase
  setup do
    @temple = create_temple
    @temple.update!(hero_images: {
      "home" => "https://cdn.example/home.jpg",
      "news" => "https://cdn.example/news.jpg",
      "archive" => "https://cdn.example/archive.jpg"
    })
  end

  def save_with(hero_images)
    Admin::TempleProfileForm
      .new(temple: @temple, params: { name: @temple.name, hero_images: hero_images })
      .save(current_admin: nil)
    @temple.reload
  end

  test "a partial submission leaves omitted tabs alone" do
    save_with({ "news" => "https://cdn.example/news-v2.jpg" })

    assert_equal "https://cdn.example/news-v2.jpg", @temple.hero_images["news"]
    assert_equal "https://cdn.example/home.jpg", @temple.hero_images["home"]
    assert_equal "https://cdn.example/archive.jpg", @temple.hero_images["archive"]
  end

  test "a submitted blank still clears that one key" do
    save_with({ "news" => "" })

    refute @temple.hero_images.key?("news")
    assert_equal "https://cdn.example/home.jpg", @temple.hero_images["home"]
    assert_equal "https://cdn.example/archive.jpg", @temple.hero_images["archive"]
  end

  test "an empty submission changes nothing" do
    save_with({})

    assert_equal %w[archive home news].sort, @temple.hero_images.keys.sort
  end

  test "unknown keys are ignored rather than stored" do
    save_with({ "news" => "https://cdn.example/n.jpg", "not_a_tab" => "https://evil.example/x.jpg" })

    refute @temple.hero_images.key?("not_a_tab")
    assert_equal "https://cdn.example/n.jpg", @temple.hero_images["news"]
  end
end
