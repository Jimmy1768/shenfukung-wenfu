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

  # The image upload used to need a separate Upload press, and nothing stopped
  # the form saving with a file chosen but never uploaded -- the URL field went
  # up empty and the picture was silently lost. Selecting a file now uploads it,
  # and a submit guard blocks a save while a file is still sitting unsent.
  test "the upload widget uploads on selection and guards the save" do
    get new_admin_gathering_path

    assert_response :success
    assert_includes response.body, "data-media-upload-context=\"gathering_hero\"",
      "the gathering form must still mount the shared upload widget"
    assert_includes response.body, "if (hasFile) runUpload();",
      "choosing a file must start the upload without a second button press"
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
