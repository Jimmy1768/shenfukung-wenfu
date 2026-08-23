require "test_helper"

class TempleRegistrationTest < ActiveSupport::TestCase
  test "admin completion gates checkout readiness for offering registrations" do
    temple = create_temple
    offering = create_offering(temple:)
    user = User.create!(email: "completion-gate@example.test", english_name: "Completion Gate", encrypted_password: User.password_hash("Password123!"))
    registration = create_registration(user:, offering:, admin_completed_at: nil)

    refute registration.admin_completed?
    assert registration.admin_completion_required?
    refute registration.checkout_ready?

    registration.mark_admin_completed!
    assert registration.admin_completed?
    assert registration.checkout_ready?
  end

  test "mark_admin_completed! is idempotent and does not overwrite the original timestamp" do
    temple = create_temple
    offering = create_offering(temple:)
    user = User.create!(email: "idempotent-completion@example.test", english_name: "Idempotent", encrypted_password: User.password_hash("Password123!"))
    registration = create_registration(user:, offering:, admin_completed_at: nil)

    assert registration.mark_admin_completed!
    first_timestamp = registration.admin_completed_at
    travel 1.hour do
      refute registration.mark_admin_completed!
    end

    assert_equal first_timestamp, registration.reload.admin_completed_at
  end

  test "gathering registrations never require admin completion, even with the flag unset" do
    temple = create_temple
    gathering = temple.temple_gatherings.create!(
      slug: "completion-gate-gathering",
      title: "Completion Gate Gathering",
      currency: "TWD",
      price_cents: 450,
      status: "published",
      starts_on: Date.current
    )
    user = User.create!(email: "gathering-completion@example.test", english_name: "Gathering Completion", encrypted_password: User.password_hash("Password123!"))
    registration = TempleEventRegistration.create!(
      temple:,
      registrable: gathering,
      user:,
      reference_code: "REG-GATHER1",
      quantity: 1,
      unit_price_cents: gathering.price_cents,
      total_price_cents: gathering.price_cents,
      currency: gathering.currency,
      payment_status: "pending",
      fulfillment_status: "open",
      contact_payload: { "name" => user.english_name },
      admin_completed_at: nil
    )

    refute registration.admin_completion_required?
    refute registration.admin_completed?
    assert registration.checkout_ready?
  end
end
