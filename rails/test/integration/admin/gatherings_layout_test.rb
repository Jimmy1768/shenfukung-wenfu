require "test_helper"

class AdminGatheringsLayoutTest < ActionDispatch::IntegrationTest
  setup do
    @temple = create_temple
    @admin = create_admin_user(
      temple: @temple,
      role: "admin",
      permission_overrides: { manage_offerings: true }
    )
    sign_in_admin(@admin)
  end

  test "new gathering form renders as fluid two-column stage" do
    get new_admin_gathering_path

    assert_response :success
    assert_includes response.body, 'class="form-stack stack-item stack-item--fluid gathering-form"'
    assert_includes response.body, 'class="offering-form-stage gathering-form-stage"'
    assert_includes response.body, 'class="offering-form-stage__primary"'
    assert_includes response.body, 'class="offering-form-stage__secondary-list"'
    assert_select "input[name='temple_gathering[title]']"
    assert_select "input[name='temple_gathering[price_cents]']"
    assert_select "input[name='temple_gathering[hero_asset_id]']"
    assert_select "textarea[name='temple_gathering[location_notes]']"
  end

  # Uploading is a deliberate press, not automatic on selection: on an edit form
  # it replaces an image that is already live. What the guard fixes is the
  # silent loss -- the form used to save happily with a file chosen but never
  # uploaded, sending an empty URL up over the picture.
  # Pressing 上傳 on an existing gathering must store the image then and there.
  # It used to only fill a form field, so the picture was not saved until the
  # admin scrolled down and pressed the page's Save -- and if they did not, it
  # was lost silently, which is exactly what happened on 消防救生活動.
  test "uploading saves the image straight to an existing gathering" do
    gathering = @temple.temple_gatherings.create!(
      slug: "hero-attach", title: "Hero Attach", currency: "TWD", price_cents: 0
    )
    asset = @temple.media_assets.create!(
      role: "gathering_hero",
      file_uid: "prod/gatherings/hero/#{@temple.slug}/abc.jpg",
      metadata: { "url" => "https://cdn.example/gathering-hero.jpg" }
    )

    patch hero_image_admin_gathering_path(gathering), params: { asset_id: asset.id }

    assert_response :success
    gathering.reload
    assert_equal "https://cdn.example/gathering-hero.jpg", gathering.hero_image_url,
      "the image must be stored without the admin pressing the page's Save"
    assert_equal asset.id, gathering.hero_asset_id
  end

  test "an edit form offers the immediate save, a new one cannot" do
    gathering = @temple.temple_gatherings.create!(
      slug: "hero-attach-form", title: "Hero Attach Form", currency: "TWD", price_cents: 0
    )

    get edit_admin_gathering_path(gathering)
    assert_response :success
    assert_includes response.body, hero_image_admin_gathering_path(gathering),
      "editing an existing gathering must wire the immediate save"

    get new_admin_gathering_path
    assert_response :success
    refute_includes response.body, "data-media-upload-attach-url",
      "a new gathering has no record to attach to yet"
  end

  test "uploading stays an explicit press, and the save is guarded" do
    get new_admin_gathering_path

    assert_response :success
    assert_includes response.body, "data-media-upload-context=\"gathering_hero\"",
      "the gathering form must still mount the shared upload widget"
    assert_select "[data-media-upload-button]", true,
      "choosing a file must not upload on its own -- the admin presses Upload"
    refute_includes response.body, "if (hasFile) runUpload();",
      "selection must not trigger the upload"
    assert_includes response.body, "mediaUploadGuarded",
      "the form must refuse to save while a chosen file has not been uploaded"
    assert_includes response.body, I18n.t("admin.media_uploads.status.not_uploaded"),
      "the guard needs a message the admin can act on"
  end

  test "gathering form still submits existing params" do
    assert_difference -> { @temple.temple_gatherings.count }, 1 do
      post admin_gatherings_path, params: {
        temple_gathering: {
          title: "Community Tea",
          subtitle: "Monthly meetup",
          description: "A simple gathering for temple members.",
          free_gathering: "0",
          price_cents: "200",
          currency: "TWD",
          starts_on: Date.current,
          ends_on: Date.current,
          start_time: "09:00",
          end_time: "10:00",
          location_name: "Main Hall",
          location_address: "1 Temple Road",
          location_notes: "Enter through the side gate.",
          status: "draft",
          hero_image_url: "https://example.test/gathering.jpg"
        }
      }
    end

    assert_redirected_to admin_gatherings_path
    gathering = @temple.temple_gatherings.find_by!(title: "Community Tea")
    assert_equal "Monthly meetup", gathering.subtitle
    assert_equal 20_000, gathering.price_cents
    assert_equal "TWD", gathering.currency
    assert_equal "Main Hall", gathering.location_name
    assert_equal "draft", gathering.status
  end
end
