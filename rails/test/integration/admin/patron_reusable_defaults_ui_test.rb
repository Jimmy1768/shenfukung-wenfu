require "test_helper"

# Drives the new admin "Reusable defaults" panel embedded in the
# admin/offering_orders edit screen through its real rendered HTML forms
# (not a controller-level JSON shortcut), then confirms the value it wrote
# actually appears as a default on a subsequent, different patron-facing
# registration form for the same offering -- the whole point of the panel.
class Admin::PatronReusableDefaultsUiTest < ActionDispatch::IntegrationTest
  setup do
    @temple = create_temple
    @admin = create_admin_user(temple: @temple)
    AdminPermission.find_by(admin_account: @admin.admin_account, temple: @temple)
      .update!(manage_registrations: true)

    @event = TempleOffering.create!(
      temple: @temple,
      slug: "spring-rite-#{SecureRandom.hex(3)}",
      title: "Spring Rite",
      starts_on: Date.current,
      ends_on: Date.current + 1.day,
      offering_type: "general",
      currency: "TWD",
      price_cents: 1000
    )

    @patron = User.create!(
      email: "patron-#{SecureRandom.hex(3)}@example.com",
      english_name: "Patron Household",
      encrypted_password: User.password_hash("Password123!")
    )
    @dependent = Dependent.create!(english_name: "Family Member")
    UserDependent.create!(user: @patron, dependent: @dependent, role: "family", relationship_label: "Family")

    # An existing registration under a *different* registrant scope than the
    # one we'll later check on the patron side, purely so there's something
    # for admin to open in "edit" mode -- the reusable defaults panel only
    # renders there. It deliberately carries no arrival_window yet.
    @registration = create_registration(
      user: @patron,
      offering: @event,
      metadata: { "registrant_scope" => "dependent", "dependent_id" => @dependent.id.to_s, "registrant_name" => @dependent.english_name }
    )
  end

  test "admin sets a reusable default through the embedded UI and it prefills the patron's next registration" do
    sign_in_admin(@admin)

    edit_path = edit_admin_event_offering_order_path(@event, @registration)
    get edit_path
    assert_response :success

    assert_select "#reusable-defaults-panel" do
      assert_select "[data-reusable-default-field='arrival_window']" do
        assert_select ".reusable-default-current .muted", text: I18n.t("admin.registration_form.labels.no_value")

        assert_select "form.reusable-default-set-form" do |forms|
          form = forms.first
          assert_equal admin_patron_metadata_values_path(@patron), form["action"]
          assert_select form, "input[name='field'][value='arrival_window']", 1
          assert_select form, "input[name='offering_kind'][value='TempleEvent']", 1
          assert_select form, "input[name='offering_id'][value=?]", @event.id.to_s
          assert_select form, "input[name='return_to'][value=?]", edit_path
          assert_select form, "input[name='value']", 1
        end
      end
    end

    # Submit exactly what that rendered form would submit.
    post admin_patron_metadata_values_path(@patron), params: {
      field: "arrival_window",
      value: "Please arrive by 9am for check-in",
      offering_kind: "TempleEvent",
      offering_id: @event.id,
      return_to: edit_path
    }
    assert_redirected_to edit_path
    follow_redirect!
    assert_response :success
    assert_select ".admin-flash-notice", 1

    @patron.reload
    stored = Registrations::ReusableDefaults.new(user: @patron, temple: @temple, offering: @event).read
    assert_equal "Please arrive by 9am for check-in", stored["arrival_window"]

    # The edit screen itself now reflects the stored value.
    assert_select "#reusable-defaults-panel [data-reusable-default-field='arrival_window'] .reusable-default-value", text: "Please arrive by 9am for check-in"

    # A brand new patron-facing registration for the SAME offering, but a
    # different (as-yet-unregistered) scope, must show the reusable default
    # pre-filled -- proving the write actually round-trips through the
    # shared boundary, not just back onto the same registration.
    delete admin_logout_path
    sign_in_account(@patron, temple_slug: @temple.slug)

    get new_account_registration_path(offering: @event.slug, account_action: "event")
    assert_response :success
    assert_select "input[name='account_registration_intake_form[arrival_window]'][value=?]", "Please arrive by 9am for check-in"

    # -- Clear path -----------------------------------------------------
    delete account_logout_path
    sign_in_admin(@admin)

    get edit_path
    assert_response :success
    assert_select "#reusable-defaults-panel [data-reusable-default-field='arrival_window']" do
      assert_select "form.reusable-default-clear-form" do |forms|
        form = forms.first
        assert_equal admin_patron_metadata_value_path(@patron, "arrival_window"), form["action"]
      end
    end

    delete admin_patron_metadata_value_path(@patron, "arrival_window"), params: {
      field: "arrival_window",
      offering_kind: "TempleEvent",
      offering_id: @event.id,
      return_to: edit_path
    }
    assert_redirected_to edit_path

    @patron.reload
    cleared = Registrations::ReusableDefaults.new(user: @patron, temple: @temple, offering: @event).read
    assert_nil cleared["arrival_window"]
  end

  test "admin adds and clears one entry of a multi-value reusable default through the embedded UI" do
    @event.update!(
      metadata: {
        "registration_form" => {
          "field_settings" => { "incense_option" => { "allow_multiple" => true } }
        }
      }
    )
    sign_in_admin(@admin)
    edit_path = edit_admin_event_offering_order_path(@event, @registration)

    get edit_path
    assert_response :success
    assert_select "#reusable-defaults-panel [data-reusable-default-field='incense_option']" do
      assert_select "form.reusable-default-add-form" do |forms|
        form = forms.first
        assert_equal admin_patron_metadata_values_path(@patron), form["action"]
        assert_select form, "input[name='field'][value='incense_option']", 1
      end
    end

    post admin_patron_metadata_values_path(@patron), params: {
      field: "incense_option", value: "sandalwood", offering_kind: "TempleEvent", offering_id: @event.id, return_to: edit_path
    }
    assert_redirected_to edit_path

    post admin_patron_metadata_values_path(@patron), params: {
      field: "incense_option", value: "lotus", offering_kind: "TempleEvent", offering_id: @event.id, return_to: edit_path
    }
    assert_redirected_to edit_path
    follow_redirect!
    assert_response :success

    @patron.reload
    defaults = Registrations::ReusableDefaults.new(user: @patron, temple: @temple, offering: @event)
    assert_equal %w[sandalwood lotus], defaults.read["incense_option"]

    assert_select "#reusable-defaults-panel [data-reusable-default-field='incense_option'] .reusable-default-value" do |elements|
      assert_equal ["sandalwood", "lotus"], elements.map(&:text)
    end

    delete admin_patron_metadata_value_path(@patron, "incense_option"), params: {
      field: "incense_option", value: "sandalwood", offering_kind: "TempleEvent", offering_id: @event.id, return_to: edit_path
    }
    assert_redirected_to edit_path

    @patron.reload
    assert_equal ["lotus"], defaults.read["incense_option"]
  end
end
