# frozen_string_literal: true

require "test_helper"

# W2's six-state model. These assert the SCOPES, not a derived Ruby method,
# because the reason W2 exists is that pending work was unfindable at volume
# -- a state that cannot be filtered solves that with a mechanism that
# reproduces it one level up.
class RegistrationLifecycleStagesTest < ActiveSupport::TestCase
  setup do
    @temple = create_temple
    @offering = create_offering(temple: @temple, price_cents: 500)
    @free = create_offering(temple: @temple, slug: "free-#{SecureRandom.hex(2)}", price_cents: 0)
    @user = User.create!(
      email: "stages-#{SecureRandom.hex(3)}@example.com",
      english_name: "Stage Patron",
      encrypted_password: User.password_hash("Password123!")
    )
  end

  def reg(offering: @offering, **attrs)
    create_registration(user: @user, offering:, **attrs)
  end

  test "every state is expressible as a SQL scope, including through a temple association" do
    %i[awaiting_admin_completion awaiting_payment awaiting_fulfilment fulfilled cancelled].each do |scope|
      assert_nothing_raised { @temple.temple_event_registrations.public_send(scope).count }
    end
  end

  test "an incomplete registration is awaiting completion and nothing else" do
    registration = reg(admin_completed_at: nil)

    assert_includes @temple.temple_event_registrations.awaiting_admin_completion, registration
    refute_includes @temple.temple_event_registrations.awaiting_payment, registration
    refute_includes @temple.temple_event_registrations.awaiting_fulfilment, registration
    assert_equal :awaiting_admin_completion, registration.lifecycle_stage
  end

  test "a completed unpaid registration is awaiting payment" do
    registration = reg(admin_completed_at: Time.current)

    assert_includes @temple.temple_event_registrations.awaiting_payment, registration
    refute_includes @temple.temple_event_registrations.awaiting_admin_completion, registration
    assert_equal :awaiting_payment, registration.lifecycle_stage
  end

  test "delinquency relabels the same rows rather than selecting different ones" do
    registration = reg(admin_completed_at: Time.current)

    assert_equal :awaiting_payment, registration.lifecycle_stage(delinquent: false)
    assert_equal :blocked_on_billing, registration.lifecycle_stage(delinquent: true)
    # Same row either way -- which is why delinquency stays out of the scopes
    # and all six remain plain SQL.
    assert_includes @temple.temple_event_registrations.awaiting_payment, registration
  end

  test "a paid registration is awaiting fulfilment" do
    registration = reg(admin_completed_at: Time.current)
    registration.mark_paid!

    assert_includes @temple.temple_event_registrations.awaiting_fulfilment, registration
    refute_includes @temple.temple_event_registrations.awaiting_payment, registration
    assert_equal :awaiting_fulfilment, registration.lifecycle_stage
  end

  test "a free registration skips payment and is awaiting fulfilment once completed" do
    registration = reg(offering: @free, admin_completed_at: Time.current)

    assert_includes @temple.temple_event_registrations.awaiting_fulfilment, registration
    refute_includes @temple.temple_event_registrations.awaiting_payment, registration,
      "there is no payment step to wait on"
    assert_equal :awaiting_fulfilment, registration.lifecycle_stage
  end

  test "mark_fulfilled! records when, is idempotent, and reports whether it acted" do
    registration = reg(admin_completed_at: Time.current)
    registration.mark_paid!

    assert registration.mark_fulfilled!
    assert registration.fulfilled?
    assert registration.fulfilled_at.present?, "a status alone cannot answer how long this waited"

    first = registration.fulfilled_at
    refute registration.mark_fulfilled!, "second call must report that it did nothing"
    assert_equal first, registration.reload.fulfilled_at
  end

  test "a cancelled registration leaves every open queue" do
    registration = reg(admin_completed_at: nil)
    registration.update!(fulfillment_status: TempleRegistration::FULFILLMENT_STATUSES[:cancelled])

    assert_includes @temple.temple_event_registrations.cancelled, registration
    refute_includes @temple.temple_event_registrations.awaiting_admin_completion, registration
    assert_equal :cancelled, registration.lifecycle_stage
  end

  test "mark_fulfilled! refuses a cancelled registration" do
    registration = reg(admin_completed_at: Time.current)
    registration.update!(fulfillment_status: TempleRegistration::FULFILLMENT_STATUSES[:cancelled])

    refute registration.mark_fulfilled!
  end

  test "the awaiting-completion filter is distinct from unpaid" do
    incomplete = reg(admin_completed_at: nil)
    complete_unpaid = reg(offering: create_offering(temple: @temple, slug: "o2-#{SecureRandom.hex(2)}", price_cents: 500),
                          admin_completed_at: Time.current)

    unpaid = TempleEventRegistration.admin_filtered(status: "unpaid")
    awaiting = TempleEventRegistration.admin_filtered(status: "awaiting_completion")

    assert_includes unpaid, incomplete
    assert_includes unpaid, complete_unpaid, "both look identical under the old vocabulary"
    assert_includes awaiting, incomplete
    refute_includes awaiting, complete_unpaid, "the whole point: waiting on us vs waiting on them"
  end
end
