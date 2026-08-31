# frozen_string_literal: true

require "test_helper"

# Before 2026-08-31 Admin::PatronsController#patron_scope was `User.all`, so
# every temple's staff could see every account in the system -- including bare
# signups with no connection to any temple -- by name and email, and could
# reach any account's records page by id. Membership is now derived from
# actual activity with the temple.
class Admin::PatronTenantIsolationTest < ActionDispatch::IntegrationTest
  setup do
    @temple_a = create_temple
    @temple_b = create_temple
    @owner_b = create_admin_user(temple: @temple_b, role: "owner")
  end

  test "a bare signup with no temple activity is invisible to every temple" do
    stranger = User.create!(
      email: "bare-signup@example.com", english_name: "Bare Signup",
      encrypted_password: User.password_hash("Password123!")
    )
    sign_in_admin(@owner_b)

    get admin_patrons_path
    refute_includes response.body, stranger.email

    get admin_patrons_path(q: "Bare Signup")
    refute_includes response.body, stranger.email

    get admin_patrons_path(format: :json, q: stranger.email)
    assert_empty response.parsed_body.fetch("patrons")
  end

  test "a patron of another temple is neither listed nor addressable by id" do
    patron = User.create!(
      email: "only-temple-a@example.com", english_name: "Only Temple A",
      encrypted_password: User.password_hash("Password123!")
    )
    join_temple!(patron, @temple_a)

    sign_in_admin(@owner_b)

    get admin_patrons_path(format: :json, q: patron.email)
    assert_empty response.parsed_body.fetch("patrons")

    # Not reachable by guessing the id either.
    get records_admin_patron_path(patron)
    assert_response :not_found

    patch note_admin_patron_path(patron), params: { temple_patron_note: { body: "should never persist" } }
    assert_response :not_found
    assert_nil TemplePatronNote.find_by(user: patron)
  end

  test "activity of any kind establishes membership" do
    sign_in_admin(@owner_b)

    registrant = User.create!(email: "r@example.com", english_name: "By Registration",
                              encrypted_password: User.password_hash("Password123!"))
    join_temple!(registrant, @temple_b)

    asker = User.create!(email: "a@example.com", english_name: "By Assistance",
                         encrypted_password: User.password_hash("Password123!"))
    TempleAssistanceRequest.create!(temple: @temple_b, user: asker, status: "open",
                                    requested_at: Time.current, channel: "profile")

    get admin_patrons_path(format: :json)
    ids = response.parsed_body.fetch("patrons").map { |p| p["id"] }
    assert_includes ids, registrant.id
    assert_includes ids, asker.id
  end

  test "staff who never registered still appear in the admins view" do
    staff = create_admin_user(temple: @temple_b, role: "admin")
    assert_equal 0, staff.temple_event_registrations.count

    sign_in_admin(@owner_b)
    get admin_patrons_path(view: "admins")
    assert_response :success
    assert_includes response.body, staff.email
  end
end
