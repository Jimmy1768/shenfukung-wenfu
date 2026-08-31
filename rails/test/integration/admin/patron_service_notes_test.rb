# frozen_string_literal: true

require "test_helper"

class Admin::PatronServiceNotesTest < ActionDispatch::IntegrationTest
  setup do
    @temple = create_temple
    @owner = create_admin_user(temple: @temple, role: "owner")
    @patron = User.create!(
      email: "service-note-patron@example.com",
      english_name: "Service Note Patron",
      encrypted_password: User.password_hash("Password123!")
    )
  end

  test "staff can write, read back, and clear a service note" do
    sign_in_admin(@owner)

    patch note_admin_patron_path(@patron), params: {
      temple_patron_note: { body: "Attends every Ghost Festival. Prefers Mandarin." }
    }
    assert_redirected_to records_admin_patron_path(@patron)

    note = TemplePatronNote.find_by(temple: @temple, user: @patron)
    assert_equal "Attends every Ghost Festival. Prefers Mandarin.", note.body
    assert_equal @owner.admin_account, note.updated_by_admin_account

    get records_admin_patron_path(@patron)
    assert_response :success
    assert_includes response.body, "Attends every Ghost Festival"

    patch note_admin_patron_path(@patron), params: { temple_patron_note: { body: "" } }
    assert_equal "", TemplePatronNote.find_by(temple: @temple, user: @patron).body
  end

  test "the note is temple-scoped -- another temple cannot see it" do
    sign_in_admin(@owner)
    patch note_admin_patron_path(@patron), params: {
      temple_patron_note: { body: "Temple A private context" }
    }
    delete "/admin/logout"

    other_temple = create_temple
    other_owner = create_admin_user(temple: other_temple, role: "owner")
    sign_in_admin(other_owner)

    get records_admin_patron_path(@patron)
    assert_response :success
    refute_includes response.body, "Temple A private context"

    # And a write from the second temple creates its own row rather than
    # overwriting the first.
    patch note_admin_patron_path(@patron), params: {
      temple_patron_note: { body: "Temple B private context" }
    }
    assert_equal 2, TemplePatronNote.where(user: @patron).count
    assert_equal "Temple A private context", TemplePatronNote.find_by(temple: @temple, user: @patron).body
  end

  test "a service note is never reachable by the patron" do
    sign_in_admin(@owner)
    patch note_admin_patron_path(@patron), params: {
      temple_patron_note: { body: "STAFF ONLY COMMENTARY" }
    }
    delete "/admin/logout"

    # Native profile: the surface the Expo app reads.
    post "/api/v1/account/native/login", params: {
      temple_slug: @temple.slug,
      session: { email: @patron.email, password: "Password123!" }
    }
    assert_response :success
    token = response.parsed_body.dig("session", "access_token")

    %w[profile bootstrap registrations].each do |endpoint|
      get "/api/v1/account/native/#{endpoint}",
        params: { temple_slug: @temple.slug },
        headers: { "Authorization" => "Bearer #{token}" }
      assert_response :success
      refute_includes response.body, "STAFF ONLY COMMENTARY", "#{endpoint} leaked the staff note"
    end

    # And the patron's own metadata was never touched by the staff write.
    refute_includes @patron.reload.metadata.to_json, "STAFF ONLY COMMENTARY"
  end

  test "an admin without patron access cannot write a note" do
    stranger = create_admin_user(temple: @temple, role: "admin", permission_overrides: { manage_registrations: false })
    sign_in_admin(stranger)

    patch note_admin_patron_path(@patron), params: {
      temple_patron_note: { body: "should not persist" }
    }

    # Bounced to the dashboard by require_patron_access!, not merely a no-op.
    assert_redirected_to admin_dashboard_path
    assert_nil TemplePatronNote.find_by(temple: @temple, user: @patron)
  end

  test "an over-long note is rejected rather than truncated" do
    sign_in_admin(@owner)

    patch note_admin_patron_path(@patron), params: {
      temple_patron_note: { body: "x" * (TemplePatronNote::MAX_LENGTH + 1) }
    }

    assert_nil TemplePatronNote.find_by(temple: @temple, user: @patron)
  end
end
