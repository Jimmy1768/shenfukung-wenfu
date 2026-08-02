require "test_helper"

class Billing::PlatformStatementCloserTest < ActiveSupport::TestCase
  setup do
    @temple = create_temple
    @user = User.create!(
      email: "billing-#{SecureRandom.hex(2)}@example.com",
      encrypted_password: User.password_hash("Password123!"),
      english_name: "Billing Patron"
    )
    @free_offering = create_offering(temple: @temple, price_cents: 0)
    @paid_offering = create_offering(temple: @temple, price_cents: 1_000)
  end

  test "closes a Taipei calendar month with free and paid eligible registrations" do
    travel_to Time.utc(2026, 8, 1, 2, 0, 0) do
      free_registration = create_registration(
        user: @user,
        offering: @free_offering,
        payment_status: "pending",
        total_price_cents: 0,
        created_at: Time.utc(2026, 7, 31, 17, 0, 0)
      )
      paid_registration = create_registration(
        user: @user,
        offering: @paid_offering,
        payment_status: "paid",
        created_at: Time.utc(2026, 8, 1, 1, 0, 0)
      )
      create_registration(
        user: @user,
        offering: @paid_offering,
        payment_status: "failed",
        created_at: Time.utc(2026, 8, 1, 1, 0, 0)
      )

      result = Billing::PlatformStatementCloser.close(
        temple: @temple,
        month: Date.new(2026, 8),
        closed_at: Time.utc(2026, 9, 2, 1, 0, 0)
      )

      assert result.created
      assert_equal 2, result.statement.registration_count
      assert_equal 150_000, result.statement.total_cents
      assert_equal [free_registration.id, paid_registration.id].sort,
        result.statement.platform_billing_usage_records.pluck(:temple_registration_id).sort
      assert_equal "Asia/Taipei", result.statement.metadata["billing_time_zone"]
    end
  end

  test "returns the existing statement when a close is retried" do
    result = Billing::PlatformStatementCloser.close(
      temple: @temple,
      month: Date.new(2026, 8),
      closed_at: Time.utc(2026, 9, 2, 1, 0, 0)
    )
    retry_result = Billing::PlatformStatementCloser.close(
      temple: @temple,
      month: Date.new(2026, 8),
      closed_at: Time.utc(2026, 9, 2, 1, 0, 0)
    )

    assert result.created
    refute retry_result.created
    assert_equal result.statement.id, retry_result.statement.id
    assert_equal 1, @temple.platform_billing_statements.count
  end

  test "credits a registration that is cancelled after its prior period closed" do
    registration = create_registration(
      user: @user,
      offering: @free_offering,
      payment_status: "pending",
      total_price_cents: 0,
      created_at: Time.utc(2026, 8, 10, 1, 0, 0)
    )
    august = Billing::PlatformStatementCloser.close(
      temple: @temple,
      month: Date.new(2026, 8),
      closed_at: Time.utc(2026, 9, 2, 1, 0, 0)
    ).statement
    registration.update!(fulfillment_status: "cancelled", cancelled_at: Time.utc(2026, 9, 2, 1, 0, 0))

    september = Billing::PlatformStatementCloser.close(
      temple: @temple,
      month: Date.new(2026, 9),
      closed_at: Time.utc(2026, 10, 2, 1, 0, 0)
    ).statement

    assert_equal 1, september.platform_billing_adjustments.count
    adjustment = september.platform_billing_adjustments.first
    assert_equal august.id, adjustment.source_platform_billing_statement_id
    assert_equal registration.id, adjustment.temple_registration_id
    assert_equal "cancelled", adjustment.reason
    assert_equal 0, adjustment.amount_cents
  end

  test "does not include another temple's registrations" do
    other_temple = create_temple
    other_offering = create_offering(temple: other_temple, price_cents: 0)
    create_registration(user: @user, offering: other_offering, total_price_cents: 0)

    statement = Billing::PlatformStatementCloser.close(
      temple: @temple,
      month: Date.new(2026, 8),
      closed_at: Time.utc(2026, 9, 2, 1, 0, 0)
    ).statement

    assert_equal 0, statement.registration_count
  end

  test "does not close an unfinished billing month" do
    error = assert_raises(ArgumentError) do
      Billing::PlatformStatementCloser.close(temple: @temple, month: Date.new(2026, 8), closed_at: Time.utc(2026, 8, 15))
    end

    assert_equal "Billing period is not closed yet", error.message
  end
end
