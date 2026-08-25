# frozen_string_literal: true

require "test_helper"

class NativeAccountResourcesTest < ActionDispatch::IntegrationTest
  def setup
    @temple = create_temple
    @other_temple = create_temple
    @user = create_admin_user(temple: @temple, role: "owner")
    @access_token = native_login(@temple)
  end

  test "dual-role user remains scoped to their own registrations at the explicit tenant" do
    own_offering = create_offering(temple: @temple)
    other_offering = create_offering(temple: @other_temple)
    own_registration = create_registration(user: @user, offering: own_offering)
    other_user = User.create!(email: "other-#{SecureRandom.hex(3)}@example.com", english_name: "Other User", encrypted_password: User.password_hash("Password123!"))
    same_tenant_registration = create_registration(user: other_user, offering: own_offering)
    other_registration = create_registration(user: other_user, offering: other_offering)

    get "/api/v1/account/native/registrations", params: { temple_slug: @temple.slug }, headers: bearer
    assert_response :success
    assert_equal [own_registration.reference_code], response.parsed_body.fetch("registrations").map { |entry| entry.fetch("reference_code") }
    refute_includes response.body, other_registration.reference_code
    refute_includes response.body, same_tenant_registration.reference_code
    refute_includes response.body, "guest_lists"

    get "/api/v1/account/native/registrations/#{same_tenant_registration.id}", params: { temple_slug: @temple.slug }, headers: bearer
    assert_response :not_found

    get "/api/v1/account/native/registrations/#{own_registration.id}", params: { temple_slug: @other_temple.slug }, headers: bearer
    assert_response :not_found
  end

  test "profile and dependent mutations use account forms and return stable validation errors" do
    patch "/api/v1/account/native/profile", params: { temple_slug: @temple.slug, profile: { english_name: "", native_name: "" } }, headers: bearer
    assert_response :unprocessable_entity
    assert_equal "validation_failed", response.parsed_body.fetch("code")

    post "/api/v1/account/native/dependents", params: { temple_slug: @temple.slug, dependent: { english_name: "Family Member", relationship_label: "family" } }, headers: bearer
    assert_response :created
    dependent = response.parsed_body.fetch("dependent")
    assert_equal "Family Member", dependent.fetch("english_name")

    delete "/api/v1/account/native/dependents/#{dependent.fetch("id")}", params: { temple_slug: @temple.slug }, headers: bearer
    assert_response :no_content
  end

  test "closure revokes the native access session" do
    post "/api/v1/account/native/privacy/close", params: { temple_slug: @temple.slug }, headers: bearer
    assert_response :no_content

    get "/api/v1/account/native/profile", params: { temple_slug: @temple.slug }, headers: bearer
    assert_response :unauthorized
    assert_equal "account_closed", response.parsed_body.fetch("code")
  end

  test "assistance contact and privacy requests retain account-owned behavior" do
    post "/api/v1/account/native/assistance", params: { temple_slug: @temple.slug, assistance: { channel: "profile", message: "Please contact me" } }, headers: bearer
    assert_response :created
    assert_equal "open", response.parsed_body.dig("assistance_request", "status")

    sender = Minitest::Mock.new
    sender.expect :call, Struct.new(:success?).new(true)
    factory = ->(**_arguments) { sender }
    Contact::TempleInquirySender.stub(:new, factory) do
      post "/api/v1/account/native/contact", params: { temple_slug: @temple.slug, contact: { subject: "Question", message: "A sufficiently long question" } }, headers: bearer
    end
    assert_response :created
    assert_equal true, response.parsed_body.fetch("accepted")
    sender.verify

    post "/api/v1/account/native/privacy/data_export", params: { temple_slug: @temple.slug }, headers: bearer
    assert_response :created
    assert_equal "data_export", response.parsed_body.dig("privacy_request", "request_type")
  end

  test "native registration create update duplicate and gathering lifecycle reuse account forms" do
    event = @temple.temple_events.create!(slug: "event-#{SecureRandom.hex(3)}", title: "Native Event", starts_on: Date.current, ends_on: Date.current + 1.day, status: "published", price_cents: 1_200, currency: "TWD")
    create_params = { temple_slug: @temple.slug, account_action: "event", offering: event.slug, registration: { quantity: 2, contact_name: "Native Owner", contact_email: @user.email, price_cents: 1, unit_price_cents: 1, total_amount_cents: 1, currency: "USD" } }
    post "/api/v1/account/native/registrations", params: create_params, headers: bearer
    assert_response :created
    registration_id = response.parsed_body.dig("registration", "id")
    assert_equal 1_200, response.parsed_body.dig("registration", "unit_price_cents")
    assert_equal 2_400, response.parsed_body.dig("registration", "total_amount_cents")
    assert_equal "TWD", response.parsed_body.dig("registration", "currency")

    patch "/api/v1/account/native/registrations/#{registration_id}", params: { temple_slug: @temple.slug, registration: { contact_name: "Changed Owner", price_cents: 1, total_amount_cents: 1, currency: "USD", offering: "forged" } }, headers: bearer
    assert_response :success
    assert_equal 1_200, response.parsed_body.dig("registration", "unit_price_cents")
    assert_equal 2_400, response.parsed_body.dig("registration", "total_amount_cents")
    assert_equal "TWD", response.parsed_body.dig("registration", "currency")

    post "/api/v1/account/native/registrations", params: create_params, headers: bearer
    assert_response :unprocessable_entity
    assert_equal "validation_failed", response.parsed_body.fetch("code")

    gathering = @temple.temple_gatherings.create!(slug: "gathering-#{SecureRandom.hex(3)}", title: "Gathering", starts_on: Date.current, ends_on: Date.current + 1.day, status: "published", price_cents: 0, currency: "TWD")
    gathering_registration = TempleEventRegistration.create!(temple: @temple, registrable: gathering, user: @user, reference_code: "REG-#{SecureRandom.hex(3).upcase}", quantity: 1, unit_price_cents: 0, total_price_cents: 0, currency: "TWD", payment_status: "pending", fulfillment_status: "open", contact_payload: { "primary_contact" => "Native Owner" })
    patch "/api/v1/account/native/registrations/#{gathering_registration.id}", params: { temple_slug: @temple.slug, registration: { contact_name: "No Change" } }, headers: bearer
    assert_response :forbidden
    assert_equal "registration_not_editable", response.parsed_body.fetch("code")
  end

  test "native registration intake stays available while the temple's billing is frozen" do
    @temple.adopt_platform_billing_entitlement!.update!(state: "suspended")
    event = @temple.temple_events.create!(slug: "event-#{SecureRandom.hex(3)}", title: "Native Frozen Event", starts_on: Date.current, ends_on: Date.current + 1.day, status: "published", price_cents: 1_200, currency: "TWD")

    get "/api/v1/account/native/registrations/new", params: { temple_slug: @temple.slug, account_action: "event", offering: event.slug }, headers: bearer
    assert_response :success

    create_params = { temple_slug: @temple.slug, account_action: "event", offering: event.slug, registration: { quantity: 1, contact_name: "Native Frozen Patron", contact_email: @user.email } }
    assert_difference -> { TempleEventRegistration.count }, 1 do
      post "/api/v1/account/native/registrations", params: create_params, headers: bearer
    end
    assert_response :created
    assert_equal TempleEventRegistration::PAYMENT_STATUSES[:pending], TempleEventRegistration.order(:created_at).last.payment_status
  end

  test "native dependent create and eligible update share the safe write-back boundary" do
    event = @temple.temple_events.create!(
      slug: "native-defaults-#{SecureRandom.hex(3)}",
      title: "Native defaults",
      starts_on: Date.current,
      ends_on: Date.current + 1.day,
      status: "published",
      price_cents: 100,
      currency: "TWD",
      metadata: { "registration_form" => { "sections" => { "logistics" => ["arrival_window"], "ritual_metadata" => ["ceremony_notes"] } } }
    )
    dependent = Dependent.create!(english_name: "Native dependent")
    @user.user_dependents.create!(dependent:, role: "family")
    defaults = Registrations::ReusableDefaults.new(user: @user, temple: @temple, offering: event)

    post "/api/v1/account/native/registrations", params: {
      temple_slug: @temple.slug,
      offering: event.slug,
      account_action: "event",
      registration: { quantity: 1, registrant_scope: "dependent", dependent_id: dependent.id, contact_name: "Native dependent", contact_phone: "0912", arrival_window: "morning", ceremony_notes: "native initial" }
    }, headers: bearer
    assert_response :created
    registration_id = response.parsed_body.dig("registration", "id")
    @user.reload
    assert_equal({ "arrival_window" => "morning", "ceremony_notes" => "native initial" }, defaults.read)
    assert_equal "0912", dependent.reload.metadata["phone"]

    patch "/api/v1/account/native/registrations/#{registration_id}", params: {
      temple_slug: @temple.slug,
      registration: { quantity: 1, registrant_scope: "dependent", dependent_id: dependent.id, contact_name: "Native dependent", arrival_window: "afternoon", ceremony_notes: "native update" }
    }, headers: bearer
    assert_response :success
    @user.reload
    assert_equal({ "arrival_window" => "afternoon", "ceremony_notes" => "native update" }, defaults.read)

    before = defaults.read
    post "/api/v1/account/native/registrations", params: {
      temple_slug: @temple.slug,
      offering: event.slug,
      account_action: "event",
      registration: { quantity: 1, registrant_scope: "dependent", dependent_id: dependent.id, contact_name: "Native dependent", arrival_window: "must not write" }
    }, headers: bearer
    assert_response :unprocessable_content
    assert_equal before, defaults.read

    freeform_dependent_count = Dependent.count
    patch "/api/v1/account/native/registrations/#{registration_id}", params: {
      temple_slug: @temple.slug,
      registration: { contact_name: "Native dependent", ceremony_notes: "freeform ritual value" }
    }, headers: bearer
    assert_response :success
    assert_equal freeform_dependent_count, Dependent.count
  end

  test "native registration preparation keeps action and registrant choices tenant scoped" do
    service = @temple.temple_services.create!(slug: "service-#{SecureRandom.hex(3)}", title: "Native Service", status: "published", price_cents: 600, currency: "TWD")
    gathering = @temple.temple_gatherings.create!(slug: "gathering-#{SecureRandom.hex(3)}", title: "Native Gathering", starts_on: Date.current, ends_on: Date.current + 1.day, status: "published", price_cents: 300, currency: "TWD")
    dependent = Dependent.create!(english_name: "Owned Dependent")
    @user.user_dependents.create!(dependent:, role: "family")

    [[service, "service"], [gathering, "gathering"]].each do |offering, action|
      get "/api/v1/account/native/registrations/new", params: { temple_slug: @temple.slug, offering: offering.slug, account_action: action }, headers: bearer
      assert_response :success
      assert_equal action, response.parsed_body.dig("offering", "account_action")
      assert_equal offering.price_cents, response.parsed_body.dig("offering", "price_cents")
      assert_includes response.parsed_body.fetch("registrants"), { "scope" => "dependent", "id" => dependent.id, "label" => "Owned Dependent" }
    end

    post "/api/v1/account/native/registrations", params: { temple_slug: @temple.slug, offering: service.slug, account_action: "service", registration: { quantity: 1, registrant_scope: "dependent", dependent_id: dependent.id, contact_name: "Owned Dependent" } }, headers: bearer
    assert_response :created
    assert_equal "dependent", response.parsed_body.dig("registration", "registrant_scope")
    assert_equal dependent.id.to_s, response.parsed_body.dig("registration", "dependent_id")

    get "/api/v1/account/native/registrations/new", params: { temple_slug: @temple.slug, offering: service.slug, account_action: "event" }, headers: bearer
    assert_response :not_found

    foreign = Dependent.create!(english_name: "Foreign Dependent")
    post "/api/v1/account/native/registrations", params: { temple_slug: @temple.slug, offering: service.slug, account_action: "service", registration: { quantity: 1, registrant_scope: "dependent", dependent_id: foreign.id, contact_name: "Foreign" } }, headers: bearer
    assert_response :unprocessable_entity
  end

  test "native registration preparation prefills a returning patron's cached arrival_window, same as the web account form" do
    service = @temple.temple_services.create!(slug: "service-#{SecureRandom.hex(3)}", title: "Native Service", status: "published", price_cents: 600, currency: "TWD")
    Registrations::ReusableDefaults.new(user: @user, temple: @temple, offering: service).write!({ "arrival_window" => "上午" })

    get "/api/v1/account/native/registrations/new", params: { temple_slug: @temple.slug, offering: service.slug, account_action: "service" }, headers: bearer
    assert_response :success
    assert_equal "上午", response.parsed_body.dig("registration", "arrival_window")
    # ceremony_notes is intentionally included for the same reason arrival_window
    # is -- RegistrationIntakeForm exposes it and the web account flow gets it
    # "for free" -- but it's genuinely never cache-eligible
    # (Registrations::ReusableDefaults#eligible_fields only covers the schema's
    # logistics+ritual_metadata sections, which don't include ceremony_notes;
    # ceremony_location is the schema field, a different one). So it's always
    # nil here today, on both web and native alike -- not a native gap, just
    # confirming the key exists and doesn't error, not asserting a value that
    # can't currently be true.
    assert response.parsed_body.fetch("registration").key?("ceremony_notes")
  end

  test "native preference updates create account-user audit evidence without admin fields" do
    preference = UserPreference.for_user(@user)
    next_locale = preference.locale.to_s == "en" ? "zh-TW" : "en"
    before_count = SystemAuditLog.where(action: "preferences.theme_updated", user: @user).count
    patch "/api/v1/account/native/preferences", params: { temple_slug: @temple.slug, preferences: { locale: next_locale } }, headers: bearer
    assert_response :success
    assert_equal next_locale, response.parsed_body.dig("preferences", "locale")
    assert_equal before_count + 1, SystemAuditLog.where(action: "preferences.theme_updated", user: @user).count
    audit = SystemAuditLog.where(action: "preferences.theme_updated", user: @user).order(:id).last
    assert_equal "native_account_api", audit.metadata.fetch("source")
    refute audit.metadata.key?("admin_display_mode")
  end

  private

  def native_login(temple)
    post "/api/v1/account/native/login", params: { temple_slug: temple.slug, session: { email: @user.email, password: "Password123!" }, device: { device_id: "test-device", platform: "test" } }
    assert_response :success
    response.parsed_body.dig("session", "access_token")
  end

  def bearer
    { "Authorization" => "Bearer #{@access_token}" }
  end
end
