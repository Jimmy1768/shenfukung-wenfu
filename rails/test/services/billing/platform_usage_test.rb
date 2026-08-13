# frozen_string_literal: true

require "test_helper"

class Billing::PlatformUsageTest < ActiveSupport::TestCase
  setup do
    @temple = create_temple
    @user = User.create!(
      email: "platform-usage-#{SecureRandom.hex(2)}@example.com",
      encrypted_password: User.password_hash("Password123!"),
      english_name: "Platform Usage"
    )
    @free_offering = create_offering(temple: @temple, price_cents: 0)
    @paid_offering = create_offering(temple: @temple, price_cents: 1_000)
  end

  test "uses Taipei free acceptance and verified payment completion instead of registration creation" do
    free_registration = create_registration(
      user: @user, offering: @free_offering, total_price_cents: 0,
      created_at: Time.utc(2026, 7, 31, 16, 0, 0)
    )
    paid_registration = create_registration(
      user: @user, offering: @paid_offering, payment_status: "paid",
      created_at: Time.utc(2026, 7, 15, 12, 0, 0)
    )
    create_payment(registration: paid_registration, processed_at: Time.utc(2026, 8, 10, 3, 0, 0))

    usage = Billing::PlatformUsage.for_month(temple: @temple, month: Date.new(2026, 8))

    assert_equal [free_registration.id, paid_registration.id].sort, usage.registrations.map { |entry| entry.registration.id }.sort
    paid_entry = usage.registrations.find { |entry| entry.registration.id == paid_registration.id }
    assert_equal Time.utc(2026, 8, 10, 3, 0, 0), paid_entry.qualifying_at
    assert_equal "completed_cash", paid_entry.qualification_source
  end

  test "uses the earliest completed payment with a persisted historical fallback" do
    registration = create_registration(user: @user, offering: @paid_offering, payment_status: "paid")
    create_payment(registration:, processed_at: Time.utc(2026, 8, 8, 0, 0), created_at: Time.utc(2026, 8, 7, 0, 0))
    historical_payment = create_payment(registration:, processed_at: nil, created_at: Time.utc(2026, 8, 1, 0, 0))

    entry = Billing::PlatformUsage.for_month(temple: @temple, month: Date.new(2026, 8)).registrations.first

    assert_equal registration.id, entry.registration.id
    assert_equal historical_payment.created_at, entry.qualifying_at
  end

  test "excludes paid registrations that are pending failed cancelled or fully refunded while retaining fulfilled" do
    fulfilled = create_registration(user: @user, offering: @paid_offering, payment_status: "paid", fulfillment_status: "fulfilled")
    create_payment(registration: fulfilled, processed_at: Time.utc(2026, 8, 3))

    pending = create_registration(user: @user, offering: @paid_offering, payment_status: "pending")
    create_payment(registration: pending, processed_at: Time.utc(2026, 8, 3))
    failed = create_registration(user: @user, offering: @paid_offering, payment_status: "failed")
    create_payment(registration: failed, processed_at: Time.utc(2026, 8, 3))
    cancelled = create_registration(user: @user, offering: @paid_offering, payment_status: "paid", fulfillment_status: "cancelled")
    create_payment(registration: cancelled, processed_at: Time.utc(2026, 8, 3))
    refunded = create_registration(user: @user, offering: @paid_offering, payment_status: "refunded")
    create_payment(registration: refunded, processed_at: Time.utc(2026, 8, 3))

    registrations = Billing::PlatformUsage.for_month(temple: @temple, month: Date.new(2026, 8)).registrations.map(&:registration)

    assert_equal [fulfilled.id], registrations.map(&:id)
  end

  test "excludes a refunded free registration before free qualification" do
    registration = create_registration(
      user: @user,
      offering: @free_offering,
      total_price_cents: 0,
      payment_status: "refunded",
      created_at: Time.utc(2026, 8, 12, 0, 0, 0)
    )

    assert_equal "refunded", Billing::PlatformUsage.ineligible_reason(registration)
    assert_nil Billing::PlatformUsage.qualification_for(registration, temple: @temple)
    refute_includes(
      Billing::PlatformUsage.for_month(temple: @temple, month: Date.new(2026, 8)).registrations.map(&:registration),
      registration
    )
  end

  test "does not cross tenant boundaries even when registrations share a user" do
    other_temple = create_temple
    other_registration = create_registration(user: @user, offering: create_offering(temple: other_temple, price_cents: 0), total_price_cents: 0)

    usage = Billing::PlatformUsage.for_month(temple: @temple, month: Date.current)

    refute_includes usage.registrations.map(&:registration), other_registration
  end
end
