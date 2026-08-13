# frozen_string_literal: true

require "test_helper"

class Billing::PlatformBillingQualificationCorrectionTest < ActiveSupport::TestCase
  setup do
    @temple = create_temple
    @user = User.create!(
      email: "platform-correction-#{SecureRandom.hex(2)}@example.com",
      encrypted_password: User.password_hash("Password123!"),
      english_name: "Platform Correction"
    )
    @offering = create_offering(temple: @temple, price_cents: 0)
    @paid_offering = create_offering(temple: @temple, price_cents: 1_000)
  end

  test "persists a qualifying timestamp once despite duplicate completed payment attempts" do
    registration = create_registration(user: @user, offering: @offering, total_price_cents: 0, created_at: Time.utc(2026, 8, 10))
    statement = Billing::PlatformStatementCloser.close(
      temple: @temple, month: Date.new(2026, 8), closed_at: Time.utc(2026, 9, 2)
    ).statement

    usage_record = statement.platform_billing_usage_records.find_by!(temple_registration: registration)
    assert_equal Time.utc(2026, 8, 10), usage_record.qualifying_at
    assert_equal "free_registration", usage_record.qualification_source
    assert_equal 0, usage_record.unit_fee_cents

    retry_result = Billing::PlatformStatementCloser.close(
      temple: @temple, month: Date.new(2026, 8), closed_at: Time.utc(2026, 9, 2)
    )
    refute retry_result.created
    assert_equal 1, PlatformBillingUsageRecord.where(temple_registration: registration).count
  end

  test "reprices source aggregate for multiple arbitrary corrections instead of crediting ordinal fees" do
    source = create_source_statement(registration_count: 2_001, period_start_at: Time.utc(2026, 7, 31, 16))
    late_registration = create_registration(user: @user, offering: @paid_offering, payment_status: "paid", created_at: Time.utc(2026, 8, 28))
    early_registration = create_registration(user: @user, offering: @paid_offering, payment_status: "paid", created_at: Time.utc(2026, 8, 2))
    create_source_usage_record(statement: source, registration: late_registration, qualifying_at: late_registration.created_at)
    create_source_usage_record(statement: source, registration: early_registration, qualifying_at: early_registration.created_at)
    late_registration.update!(fulfillment_status: "cancelled")
    early_registration.update!(payment_status: "refunded")

    target = Billing::PlatformStatementCloser.close(
      temple: @temple, month: Date.new(2026, 9), closed_at: Time.utc(2026, 10, 2)
    ).statement
    adjustments = target.platform_billing_adjustments.order(:id)

    assert_equal 2, adjustments.count
    assert_equal(-225, adjustments.sum(:amount_cents))
    assert_equal [2_001, 2_000], adjustments.map { |adjustment| adjustment.metadata["source_registration_count_before_correction"] }
    assert_equal [2_000, 1_999], adjustments.map { |adjustment| adjustment.metadata["source_registration_count_after_correction"] }
    assert_equal source.usage_total_cents - 225, source.usage_total_cents + adjustments.sum(:amount_cents)
    assert_equal 2_001, source.reload.registration_count
    assert_equal source.usage_total_cents, source.reload.total_cents
  end

  test "does not create an adjustment replay or let effective source count become negative" do
    source = create_source_statement(registration_count: 1, period_start_at: Time.utc(2026, 7, 31, 16))
    first = create_registration(user: @user, offering: @offering, total_price_cents: 0)
    second = create_registration(user: @user, offering: @offering, total_price_cents: 0)
    create_source_usage_record(statement: source, registration: first, qualifying_at: Time.utc(2026, 8, 2))
    create_source_usage_record(statement: source, registration: second, qualifying_at: Time.utc(2026, 8, 3))
    first.update!(fulfillment_status: "cancelled")
    second.update!(fulfillment_status: "cancelled")

    target = Billing::PlatformStatementCloser.close(
      temple: @temple, month: Date.new(2026, 9), closed_at: Time.utc(2026, 10, 2)
    ).statement
    retry_target = Billing::PlatformStatementCloser.close(
      temple: @temple, month: Date.new(2026, 9), closed_at: Time.utc(2026, 10, 2)
    ).statement

    assert_equal target.id, retry_target.id
    assert_equal 1, target.platform_billing_adjustments.count
    assert_equal 0, target.platform_billing_adjustments.sum(:amount_cents)
    assert_equal(-1, target.platform_billing_adjustments.sum(:registration_count_delta))
  end

  test "tenant mismatch is invalid for usage records and adjustments" do
    other_temple = create_temple
    source = create_source_statement(registration_count: 1, period_start_at: Time.utc(2026, 7, 31, 16))
    other_registration = create_registration(user: @user, offering: create_offering(temple: other_temple, price_cents: 0), total_price_cents: 0)

    usage_record = PlatformBillingUsageRecord.new(
      platform_billing_statement: source, temple: @temple, temple_registration: other_registration,
      registration_created_at: Time.utc(2026, 8, 2), qualifying_at: Time.utc(2026, 8, 2),
      qualification_source: "free_registration", unit_fee_cents: 0
    )

    refute usage_record.valid?
    assert_includes usage_record.errors[:temple], "must match the registration temple"

    registration = create_registration(user: @user, offering: @offering, total_price_cents: 0)
    valid_usage_record = create_source_usage_record(statement: source, registration:, qualifying_at: Time.utc(2026, 8, 2))
    other_quote = Billing::PlatformPricingPolicy.quote(0)
    other_statement = other_temple.platform_billing_statements.create!(
      period_start_at: Time.utc(2026, 8, 31, 16), period_end_at: Time.utc(2026, 9, 30, 16),
      pricing_policy_version: Billing::PlatformPricingPolicy::VERSION, currency: "TWD", status: "closed",
      idempotency_key: "other-source-#{SecureRandom.hex(2)}", registration_count: 0,
      included_registration_count: 0, band_one_registration_count: 0, band_two_registration_count: 0,
      band_three_registration_count: 0, base_fee_cents: other_quote.base_fee_cents,
      band_one_fee_cents: 0, band_two_fee_cents: 0, band_three_fee_cents: 0,
      usage_total_cents: other_quote.usage_total_cents, total_cents: other_quote.usage_total_cents,
      closed_at: Time.utc(2026, 10, 1)
    )
    adjustment = PlatformBillingAdjustment.new(
      platform_billing_statement: other_statement, source_platform_billing_statement: source,
      platform_billing_usage_record: valid_usage_record, temple: @temple, temple_registration: registration,
      reason: "cancelled", registration_count_delta: -1, amount_cents: 0, recognized_at: Time.utc(2026, 10, 1)
    )

    refute adjustment.valid?
    assert_includes adjustment.errors[:temple], "must match the statement, usage record, and registration temple"
  end

  test "database uniqueness prevents duplicate usage and replayed adjustments" do
    source = create_source_statement(registration_count: 1, period_start_at: Time.utc(2026, 7, 31, 16))
    target = create_source_statement(registration_count: 0, period_start_at: Time.utc(2026, 8, 31, 16))
    registration = create_registration(user: @user, offering: @offering, total_price_cents: 0)
    now = Time.utc(2026, 8, 2)
    usage_attributes = {
      platform_billing_statement_id: source.id, temple_id: @temple.id, temple_registration_id: registration.id,
      registration_created_at: registration.created_at, qualifying_at: now, qualification_source: "free_registration",
      unit_fee_cents: 0, eligibility_snapshot: {}, created_at: now, updated_at: now
    }

    PlatformBillingUsageRecord.insert_all!([usage_attributes])
    assert_raises(ActiveRecord::RecordNotUnique) do
      ActiveRecord::Base.transaction(requires_new: true) { PlatformBillingUsageRecord.insert_all!([usage_attributes]) }
    end

    usage_record = PlatformBillingUsageRecord.find_by!(temple_registration: registration)
    adjustment_attributes = {
      platform_billing_statement_id: target.id, source_platform_billing_statement_id: source.id,
      platform_billing_usage_record_id: usage_record.id, temple_id: @temple.id,
      temple_registration_id: registration.id, reason: "cancelled", registration_count_delta: -1,
      amount_cents: 0, recognized_at: now, metadata: {}, created_at: now, updated_at: now
    }

    PlatformBillingAdjustment.insert_all!([adjustment_attributes])
    assert_raises(ActiveRecord::RecordNotUnique) do
      ActiveRecord::Base.transaction(requires_new: true) { PlatformBillingAdjustment.insert_all!([adjustment_attributes]) }
    end
  end

  test "historical usage records retain their persisted creation timestamp fallback" do
    source = create_source_statement(registration_count: 1, period_start_at: Time.utc(2026, 7, 31, 16))
    registration = create_registration(user: @user, offering: @offering, total_price_cents: 0)
    historical_timestamp = Time.utc(2026, 8, 2)

    PlatformBillingUsageRecord.insert_all!([{
      platform_billing_statement_id: source.id, temple_id: @temple.id, temple_registration_id: registration.id,
      registration_created_at: historical_timestamp, unit_fee_cents: 0, eligibility_snapshot: {},
      created_at: historical_timestamp, updated_at: historical_timestamp
    }])

    assert_equal historical_timestamp, PlatformBillingUsageRecord.find_by!(temple_registration: registration).qualifying_timestamp
  end

  private

  def create_source_statement(registration_count:, period_start_at:)
    quote = Billing::PlatformPricingPolicy.quote(registration_count)
    @temple.platform_billing_statements.create!(
      period_start_at:, period_end_at: period_start_at + 1.month,
      pricing_policy_version: Billing::PlatformPricingPolicy::VERSION, currency: "TWD", status: "closed",
      idempotency_key: "source-#{registration_count}-#{period_start_at.to_date.iso8601}", registration_count:,
      included_registration_count: quote.included_registration_count,
      band_one_registration_count: quote.band_one_registration_count,
      band_two_registration_count: quote.band_two_registration_count,
      band_three_registration_count: quote.band_three_registration_count,
      base_fee_cents: quote.base_fee_cents, band_one_fee_cents: quote.band_one_fee_cents,
      band_two_fee_cents: quote.band_two_fee_cents, band_three_fee_cents: quote.band_three_fee_cents,
      usage_total_cents: quote.usage_total_cents, total_cents: quote.usage_total_cents, closed_at: period_start_at + 1.month
    )
  end

  def create_source_usage_record(statement:, registration:, qualifying_at:)
    statement.platform_billing_usage_records.create!(
      temple: @temple, temple_registration: registration, registration_created_at: registration.created_at,
      qualifying_at:, qualification_source: "free_registration", unit_fee_cents: 0,
      eligibility_snapshot: { "qualifying_at" => qualifying_at.iso8601 }
    )
  end
end

class Billing::PlatformBillingQualificationConcurrencyTest < ActiveSupport::TestCase
  # The close/credit races must use independent PostgreSQL connections. A
  # transaction-local fixture would hide the prepared records from workers.
  self.use_transactional_tests = false

  def setup
    @temple = create_temple
    @user = User.create!(
      email: "platform-concurrency-#{SecureRandom.hex(2)}@example.com",
      encrypted_password: User.password_hash("Password123!"),
      english_name: "Platform Concurrency"
    )
    @offering = create_offering(temple: @temple, price_cents: 0)
  end

  def teardown
    return unless @temple

    PlatformBillingAdjustment.where(temple_id: @temple.id).delete_all
    PlatformBillingUsageRecord.where(temple_id: @temple.id).delete_all
    PlatformBillingStatement.where(temple_id: @temple.id).delete_all
    TemplePayment.where(temple_id: @temple.id).delete_all
    TempleEventRegistration.where(temple_id: @temple.id).delete_all
    TempleOffering.where(temple_id: @temple.id).delete_all
    @temple.reload.destroy! if @temple.persisted?
    @user.destroy! if @user&.persisted?
  end

  test "two independent close attempts create one statement and one usage record" do
    registration = create_registration(
      user: @user,
      offering: @offering,
      total_price_cents: 0,
      created_at: Time.utc(2026, 8, 10)
    )

    attempts = concurrently_close(month: Date.new(2026, 8), closed_at: Time.utc(2026, 9, 2))

    assert_equal 2, attempts.map { |attempt| attempt[:connection_id] }.uniq.count
    assert_equal 1, attempts.count { |attempt| attempt[:created] }
    assert_equal 1, attempts.map { |attempt| attempt[:statement_id] }.uniq.count

    statement = PlatformBillingStatement.find(attempts.first[:statement_id])
    assert_equal @temple.id, statement.temple_id
    assert_equal 1, PlatformBillingStatement.where(temple_id: @temple.id, period_start_at: statement.period_start_at).count
    assert_equal [registration.id], statement.platform_billing_usage_records.pluck(:temple_registration_id)
  end

  test "concurrent and replayed correction closes create one adjustment without mutating the source statement" do
    registration = create_registration(
      user: @user,
      offering: @offering,
      total_price_cents: 0,
      created_at: Time.utc(2026, 8, 10)
    )
    source = create_closed_source_statement(registration_count: 1, period_start_at: Time.utc(2026, 7, 31, 16))
    usage_record = source.platform_billing_usage_records.create!(
      temple: @temple,
      temple_registration: registration,
      registration_created_at: registration.created_at,
      qualifying_at: registration.created_at,
      qualification_source: "free_registration",
      unit_fee_cents: 0,
      eligibility_snapshot: { "qualifying_at" => registration.created_at.iso8601 }
    )
    immutable_source = source.attributes
    registration.update!(fulfillment_status: "cancelled")

    attempts = concurrently_close(month: Date.new(2026, 9), closed_at: Time.utc(2026, 10, 2))
    replay = Billing::PlatformStatementCloser.close(
      temple: Temple.find(@temple.id), month: Date.new(2026, 9), closed_at: Time.utc(2026, 10, 2)
    )

    assert_equal 2, attempts.map { |attempt| attempt[:connection_id] }.uniq.count
    assert_equal 1, attempts.count { |attempt| attempt[:created] }
    refute replay.created
    target = PlatformBillingStatement.find(attempts.first[:statement_id])
    adjustment = target.platform_billing_adjustments.sole
    assert_equal 1, PlatformBillingAdjustment.where(platform_billing_usage_record_id: usage_record.id).count
    assert_equal @temple.id, adjustment.temple_id
    assert_equal source.id, adjustment.source_platform_billing_statement_id
    assert_equal immutable_source, source.reload.attributes.slice(*immutable_source.keys)
  end

  private

  def concurrently_close(month:, closed_at:)
    ready = Queue.new
    start = Queue.new
    results = Queue.new

    workers = 2.times.map do
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do |connection|
          ready << true
          start.pop
          result = Billing::PlatformStatementCloser.close(
            temple: Temple.find(@temple.id), month:, closed_at:
          )
          results << {
            connection_id: connection.object_id,
            created: result.created,
            statement_id: result.statement.id
          }
        end
      rescue StandardError => error
        results << error
      end
    end

    2.times { ready.pop }
    2.times { start << true }
    workers.each(&:join)
    attempts = 2.times.map { results.pop }
    failures = attempts.grep(StandardError)
    assert_empty failures, failures.map(&:message).join("\n")

    attempts.reject { |attempt| attempt.is_a?(StandardError) }
  end

  def create_closed_source_statement(registration_count:, period_start_at:)
    quote = Billing::PlatformPricingPolicy.quote(registration_count)
    @temple.platform_billing_statements.create!(
      period_start_at:,
      period_end_at: period_start_at + 1.month,
      pricing_policy_version: Billing::PlatformPricingPolicy::VERSION,
      currency: "TWD",
      status: "closed",
      idempotency_key: "concurrent-source-#{SecureRandom.hex(2)}",
      registration_count:,
      included_registration_count: quote.included_registration_count,
      band_one_registration_count: quote.band_one_registration_count,
      band_two_registration_count: quote.band_two_registration_count,
      band_three_registration_count: quote.band_three_registration_count,
      base_fee_cents: quote.base_fee_cents,
      band_one_fee_cents: quote.band_one_fee_cents,
      band_two_fee_cents: quote.band_two_fee_cents,
      band_three_fee_cents: quote.band_three_fee_cents,
      usage_total_cents: quote.usage_total_cents,
      total_cents: quote.usage_total_cents,
      closed_at: period_start_at + 1.month
    )
  end
end
