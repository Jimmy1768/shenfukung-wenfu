# frozen_string_literal: true

require "test_helper"

class NativeAccountContractTest < ActionDispatch::IntegrationTest
  def setup
    @temple = create_temple
    @user = User.create!(
      email: "contract-#{SecureRandom.hex(3)}@example.com",
      english_name: "Contract User",
      encrypted_password: User.password_hash("Password123!")
    )
    @access_token = native_login(@user)
  end

  test "signup and logout have stable account-safe session contracts" do
    email = "signup-#{SecureRandom.hex(3)}@example.com"
    post "/api/v1/account/native/signup", params: {
      temple_slug: @temple.slug,
      signup: { email:, password: "Password123!", password_confirmation: "Password123!" },
      device: { device_id: "signup-device", platform: "ios" }
    }

    assert_response :created
    assert_equal %w[session user], response.parsed_body.keys.sort
    assert_account_safe_user(response.parsed_body.fetch("user"), email:)
    assert_session_contract(response.parsed_body.fetch("session"))

    post "/api/v1/account/native/signup", params: {
      temple_slug: @temple.slug,
      signup: { email:, password: "Password123!", password_confirmation: "Password123!" }
    }
    assert_response :unprocessable_entity
    assert_equal "validation_failed", response.parsed_body.fetch("code")

    session = native_login(@user, include_refresh: true)
    delete "/api/v1/account/native/logout", params: { temple_slug: @temple.slug, refresh_token: session.fetch("refresh_token") }, headers: bearer(session.fetch("access_token"))
    assert_response :no_content

    get "/api/v1/account/native/profile", params: { temple_slug: @temple.slug }, headers: bearer(session.fetch("access_token"))
    assert_response :unauthorized
    assert_equal "session_revoked", response.parsed_body.fetch("code")
  end

  test "profile update and password addition retain account-only response contracts" do
    patch "/api/v1/account/native/profile", params: {
      temple_slug: @temple.slug,
      profile: { english_name: "Updated Contract User", city: "Taipei" }
    }, headers: bearer
    assert_response :success
    assert_account_safe_user(response.parsed_body.fetch("user"), email: @user.email)
    assert_equal "Updated Contract User", response.parsed_body.dig("user", "english_name")
    assert_equal "Taipei", response.parsed_body.dig("user", "city")

    passwordless_user = User.create!(
      email: "password-add-#{SecureRandom.hex(3)}@example.com",
      english_name: "Password Add User",
      encrypted_password: User.password_hash("OAuthSeededPlaceholder!"),
      metadata: { "oauth_seeded" => true }
    )
    access_token = direct_native_access(passwordless_user)
    post "/api/v1/account/native/profile/password", params: {
      temple_slug: @temple.slug,
      password: { password: "NewPassword123!", password_confirmation: "NewPassword123!" }
    }, headers: bearer(access_token)
    assert_response :no_content
    assert_equal User.password_hash("NewPassword123!"), passwordless_user.reload.encrypted_password

    post "/api/v1/account/native/profile/password", params: {
      temple_slug: @temple.slug,
      password: { password: "AnotherPassword123!", password_confirmation: "AnotherPassword123!" }
    }, headers: bearer(access_token)
    assert_response :unprocessable_entity
    assert_equal "validation_failed", response.parsed_body.fetch("code")
  end

  test "dependent index show and update return stable account-owned records" do
    post "/api/v1/account/native/dependents", params: {
      temple_slug: @temple.slug,
      dependent: { english_name: "Contract Dependent", relationship_label: "family" }
    }, headers: bearer
    assert_response :created
    dependent = response.parsed_body.fetch("dependent")
    assert_dependent_contract(dependent)

    get "/api/v1/account/native/dependents", params: { temple_slug: @temple.slug }, headers: bearer
    assert_response :success
    assert_equal [dependent.fetch("id")], response.parsed_body.fetch("dependents").map { |entry| entry.fetch("id") }

    get "/api/v1/account/native/dependents/#{dependent.fetch("id")}", params: { temple_slug: @temple.slug }, headers: bearer
    assert_response :success
    assert_dependent_contract(response.parsed_body.fetch("dependent"))

    other_owner = User.create!(email: "other-owner-#{SecureRandom.hex(3)}@example.com", english_name: "Other Owner", encrypted_password: User.password_hash("Password123!"))
    other_dependent = Dependent.create!(english_name: "Other Dependent")
    foreign_link = other_owner.user_dependents.create!(dependent: other_dependent, role: "family")
    get "/api/v1/account/native/dependents/#{foreign_link.id}", params: { temple_slug: @temple.slug }, headers: bearer
    assert_response :not_found
    assert_equal "not_found", response.parsed_body.fetch("code")

    patch "/api/v1/account/native/dependents/#{dependent.fetch("id")}", params: {
      temple_slug: @temple.slug,
      dependent: { english_name: "Updated Dependent", relationship_label: "family" }
    }, headers: bearer
    assert_response :success
    assert_equal "Updated Dependent", response.parsed_body.dig("dependent", "english_name")
  end

  test "account resource reads expose only the current tenant's safe presentation data" do
    event = create_event
    service = @temple.temple_services.create!(
      slug: "service-#{SecureRandom.hex(3)}", title: "Contract Service", status: "published", price_cents: 0, currency: "TWD"
    )
    gallery = @temple.temple_gallery_entries.create!(title: "Contract Gallery", body: "Account-safe gallery text", event_date: Time.current)
    registration = create_registration(user: @user, offering: event)
    registration.certificate_number = "CERT-#{SecureRandom.hex(3).upcase}"
    registration.save!

    get "/api/v1/account/native/events", params: { temple_slug: @temple.slug }, headers: bearer
    assert_response :success
    event_payload = response.parsed_body.fetch("events").first
    assert_equal event.slug, event_payload.fetch("slug")
    assert_equal "event", event_payload.fetch("account_action")
    assert_equal event.price_cents, event_payload.fetch("price_cents")
    assert_equal event.currency, event_payload.fetch("currency")
    refute response.body.include?("guest_lists")

    get "/api/v1/account/native/services", params: { temple_slug: @temple.slug }, headers: bearer
    assert_response :success
    service_payload = response.parsed_body.fetch("services").first
    assert_equal service.slug, service_payload.fetch("slug")
    assert_equal "service", service_payload.fetch("account_action")
    assert_equal service.price_cents, service_payload.fetch("price_cents")

    get "/api/v1/account/native/galleries", params: { temple_slug: @temple.slug }, headers: bearer
    assert_response :success
    assert_equal gallery.id, response.parsed_body.fetch("galleries").first.fetch("id")

    get "/api/v1/account/native/galleries/#{gallery.id}", params: { temple_slug: @temple.slug }, headers: bearer
    assert_response :success
    assert_equal gallery.id, response.parsed_body.dig("gallery", "id")

    get "/api/v1/account/native/certificates", params: { temple_slug: @temple.slug }, headers: bearer
    assert_response :success
    certificate = response.parsed_body.fetch("certificates").first
    assert_equal registration.certificate_number, certificate.fetch("certificate_number")
    assert_equal @user.email, certificate.dig("registrant", "email")
    refute response.body.include?("provider_reference")
  end

  test "registration new and edit contracts preserve account-only lifecycle state" do
    event = create_event
    registration = create_registration(user: @user, offering: event)

    get "/api/v1/account/native/registrations/new", params: {
      temple_slug: @temple.slug, account_action: "event", offering: event.slug
    }, headers: bearer
    assert_response :success
    assert_equal event.slug, response.parsed_body.dig("offering", "slug")
    assert_equal "event", response.parsed_body.dig("offering", "account_action")
    assert_equal event.price_cents, response.parsed_body.dig("offering", "price_cents")
    assert_equal event.currency, response.parsed_body.dig("offering", "currency")
    assert response.parsed_body.fetch("registration").key?("quantity")
    assert_equal "self", response.parsed_body.fetch("registrants").first.fetch("scope")
    refute response.body.include?("provider_reference")

    get "/api/v1/account/native/registrations/#{registration.id}/edit", params: { temple_slug: @temple.slug }, headers: bearer
    assert_response :success
    contract = response.parsed_body.fetch("registration")
    assert_equal registration.reference_code, contract.fetch("reference_code")
    assert_equal registration.payment_status, contract.fetch("payment_state")
    assert_equal registration.total_price_cents, contract.fetch("total_amount_cents")
    assert_equal registration.unit_price_cents, contract.fetch("unit_price_cents")
    assert_equal registration.currency, contract.dig("offering", "currency")
    refute response.body.include?("checkout")
  end

  test "registration payloads expose lifecycle_stage for every patron-visible state" do
    free_event = create_event
    paid_event = create_priced_event

    awaiting_admin = create_registration(user: @user, offering: paid_event, admin_completed_at: nil)
    awaiting_payment = create_registration(user: @user, offering: paid_event)
    awaiting_fulfilment = create_registration(user: @user, offering: free_event)
    fulfilled = create_registration(user: @user, offering: free_event, fulfillment_status: "fulfilled")

    get "/api/v1/account/native/registrations", params: { temple_slug: @temple.slug }, headers: bearer
    assert_response :success

    stages = response.parsed_body.fetch("registrations").to_h { |row| [row.fetch("id"), row.fetch("lifecycle_stage")] }

    assert_equal "awaiting_admin_completion", stages.fetch(awaiting_admin.id)
    assert_equal "awaiting_payment", stages.fetch(awaiting_payment.id)
    assert_equal "awaiting_fulfilment", stages.fetch(awaiting_fulfilment.id)
    assert_equal "fulfilled", stages.fetch(fulfilled.id)

    # The coarse field the shipped build reads must survive alongside it.
    assert response.parsed_body.fetch("registrations").all? { |row| row.key?("lifecycle") }
  end

  test "a temple whose settlement is frozen reports blocked_on_billing, not awaiting_payment" do
    paid_event = create_priced_event
    registration = create_registration(user: @user, offering: paid_event)

    get "/api/v1/account/native/registrations/#{registration.id}", params: { temple_slug: @temple.slug }, headers: bearer
    assert_response :success
    assert_equal "awaiting_payment", response.parsed_body.dig("registration", "lifecycle_stage")

    @temple.adopt_platform_billing_entitlement!.update!(state: "suspended")
    assert @temple.payment_settlement_frozen?, "precondition: the temple must be frozen"

    get "/api/v1/account/native/registrations/#{registration.id}", params: { temple_slug: @temple.slug }, headers: bearer
    assert_response :success
    assert_equal "blocked_on_billing", response.parsed_body.dig("registration", "lifecycle_stage")

    # Intake is never blocked -- only settlement. The patron must still be
    # able to register; the stage is what changes.
    assert_equal "open", response.parsed_body.dig("registration", "lifecycle")
  end

  # Rule 3 of the personal/offering data model: authorship and visibility are
  # separate axes. This pins the mechanism only -- values written into the
  # UserMetadataUpdater::NAMESPACE scope are never serialized back to the
  # patron, because the native profile reads top-level metadata only.
  #
  # It deliberately does NOT assert that top-level metadata["notes"] is a
  # designed patron-authored field. It is not. That attribute arrived with the
  # initial scaffold (9e06dcc) as part of a generic name/phone/city/notes user
  # shape, is labelled a bare "備註"/"Notes" with no stated purpose, and the
  # only recorded intent for the value -- admin/patrons_controller.rb's
  # "how do we reach them" -- treats it as contact detail. Whether a patron
  # should have a free-text note about themselves at all is an open product
  # question, not something this test blesses.
  test "admin-written registration contact notes never reach the patron profile" do
    @user.update!(metadata: (@user.metadata || {}).merge(
      "notes" => "patron's own note",
      "phone" => "0900-000-000",
      Registrations::UserMetadataUpdater::NAMESPACE => {
        "notes" => "admin note about this patron",
        "phone" => "0911-111-111"
      }
    ))

    get "/api/v1/account/native/profile", params: { temple_slug: @temple.slug }, headers: bearer
    assert_response :success
    user = response.parsed_body.fetch("user")

    assert_equal "patron's own note", user["notes"]
    assert_equal "0900-000-000", user["phone"]

    refute_includes response.body, "admin note about this patron"
    refute_includes response.body, "0911-111-111"
    refute_includes response.body, Registrations::UserMetadataUpdater::NAMESPACE

    # The admin side still resolves its own scoped value, so this is a
    # visibility boundary and not merely an unwritten field.
    assert_equal "admin note about this patron", Registrations::ReusableContact.read(@user.reload, :notes)
  end

  test "privacy show returns only the authenticated account user's requests" do
    request_record = @user.privacy_requests.create!(request_type: "data_export", status: "pending", submitted_via: "web", requested_at: Time.current)

    get "/api/v1/account/native/privacy", params: { temple_slug: @temple.slug }, headers: bearer
    assert_response :success
    privacy_request = response.parsed_body.fetch("privacy_requests").first
    assert_equal request_record.id, privacy_request.fetch("id")
    assert_equal "data_export", privacy_request.fetch("request_type")
    assert_equal "pending", privacy_request.fetch("status")
    refute response.body.include?("admin_account")
  end

  private

  def native_login(user, include_refresh: false)
    post "/api/v1/account/native/login", params: {
      temple_slug: @temple.slug,
      session: { email: user.email, password: "Password123!" },
      device: { device_id: "contract-device", platform: "ios" }
    }
    assert_response :success
    session = response.parsed_body.fetch("session")
    include_refresh ? session : session.fetch("access_token")
  end

  def direct_native_access(user)
    issued = Auth::RefreshToken.new(user).issue!(context: { device_id: "password-add-device", platform: "ios" })
    Auth::JwtService.encode({ "sub" => user.id, "native_session_id" => issued.record.id, "scope" => "account" })
  end

  def create_event
    @temple.temple_events.create!(
      slug: "event-#{SecureRandom.hex(3)}", title: "Contract Event", starts_on: Date.current,
      ends_on: Date.current + 1.day, status: "published", price_cents: 0, currency: "TWD"
    )
  end

  def create_priced_event
    @temple.temple_events.create!(
      slug: "paid-event-#{SecureRandom.hex(3)}", title: "Priced Contract Event", starts_on: Date.current,
      ends_on: Date.current + 1.day, status: "published", price_cents: 50_000, currency: "TWD"
    )
  end

  def bearer(access_token = @access_token)
    { "Authorization" => "Bearer #{access_token}" }
  end

  def assert_session_contract(session)
    assert_equal %w[access_token expires_in refresh_token token_type], session.keys.sort
    assert_equal "Bearer", session.fetch("token_type")
    assert session.fetch("access_token").present?
    assert session.fetch("refresh_token").present?
  end

  def assert_account_safe_user(user, email:)
    assert_equal email, user.fetch("email")
    assert_includes user.keys, "id"
    refute user.key?("admin_account")
    refute user.key?("roles")
    refute user.key?("provider_reference")
  end

  def assert_dependent_contract(dependent)
    assert_equal %w[dependent_id english_name id relationship_label], dependent.keys.sort
    refute dependent.key?("admin_account")
  end
end
