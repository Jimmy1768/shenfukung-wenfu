# frozen_string_literal: true

require "test_helper"

class RegistrationQueuesTest < ActionDispatch::IntegrationTest
  setup do
    @temple = create_temple
    @admin = create_admin_user(temple: @temple, permission_overrides: { manage_registrations: true })
    @offering = create_offering(temple: @temple, title: "Queue Offering", price_cents: 500)
    @patron = User.create!(
      email: "queues-#{SecureRandom.hex(3)}@example.com",
      english_name: "Queue Patron",
      encrypted_password: User.password_hash("Password123!")
    )
  end

  test "an admin can record stage 9 fulfilment, audited and idempotent" do
    registration = create_registration(user: @patron, offering: @offering, admin_completed_at: Time.current)
    registration.mark_paid!
    sign_in_admin(@admin)

    assert_difference -> { SystemAuditLog.where(action: "temple.registration.fulfilled").count }, 1 do
      post fulfil_admin_event_offering_order_path(@offering, registration)
    end
    assert registration.reload.fulfilled?
    assert registration.fulfilled_at.present?

    # Re-pressing must not log a second event -- same guarantee as completion.
    assert_no_difference -> { SystemAuditLog.where(action: "temple.registration.fulfilled").count } do
      post fulfil_admin_event_offering_order_path(@offering, registration)
    end
  end

  test "bulk completion clears a queue in one action and audits the set" do
    registrations = 3.times.map do |i|
      create_registration(
        user: User.create!(email: "bulk-#{i}-#{SecureRandom.hex(2)}@example.com",
                           english_name: "Bulk #{i}",
                           encrypted_password: User.password_hash("Password123!")),
        offering: @offering, admin_completed_at: nil
      )
    end
    sign_in_admin(@admin)

    assert_difference -> { SystemAuditLog.where(action: "temple.registration.admin_completed_bulk").count }, 1 do
      post complete_many_admin_event_offering_orders_path(@offering)
    end

    registrations.each { |r| assert r.reload.admin_completed?, "a 200-signup free event cannot be 200 clicks" }
  end

  test "bulk completion can be narrowed to a chosen subset" do
    a = create_registration(user: @patron, offering: @offering, admin_completed_at: nil)
    other = create_registration(
      user: User.create!(email: "subset-#{SecureRandom.hex(2)}@example.com", english_name: "Subset",
                         encrypted_password: User.password_hash("Password123!")),
      offering: @offering, admin_completed_at: nil
    )
    sign_in_admin(@admin)

    post complete_many_admin_event_offering_orders_path(@offering), params: { registration_ids: [a.id] }

    assert a.reload.admin_completed?
    refute other.reload.admin_completed?
  end

  test "bulk completion is a no-op when the queue is already empty" do
    create_registration(user: @patron, offering: @offering, admin_completed_at: Time.current)
    sign_in_admin(@admin)

    assert_no_difference -> { SystemAuditLog.where(action: "temple.registration.admin_completed_bulk").count } do
      post complete_many_admin_event_offering_orders_path(@offering)
    end
  end

  test "the dashboard reports awaiting-completion rather than every open registration" do
    create_registration(user: @patron, offering: @offering, admin_completed_at: nil)
    done = create_registration(
      user: User.create!(email: "done-#{SecureRandom.hex(2)}@example.com", english_name: "Done",
                         encrypted_password: User.password_hash("Password123!")),
      offering: @offering, admin_completed_at: Time.current
    )
    done.mark_paid!
    done.mark_fulfilled!
    sign_in_admin(@admin)

    get admin_dashboard_path
    assert_response :success
    # The old metric counted both of these as "pending", which told an admin
    # nothing. Only the first is actually waiting on the temple.
    assert_equal 1, @temple.temple_event_registrations.awaiting_admin_completion.count
    assert_equal 0, @temple.temple_event_registrations.awaiting_fulfilment.count
  end
end
