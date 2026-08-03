require "test_helper"

class Billing::PlatformBillingLifecycleTest < ActiveSupport::TestCase
  test "persists and audits failed collection through overdue grace and frozen" do
    temple = create_temple(payment_provider_settings: { "billing" => { "stripe_payment_method_id" => "pm_1" } })
    delivery = temple.platform_billing_deliveries.create!(kind: "monthly", status: "collecting", currency: "TWD", idempotency_key: "lifecycle-1")
    failed_at = Time.utc(2026, 8, 1)

    Billing::PlatformBillingLifecycle.record_failure!(delivery:, now: failed_at)
    assert_equal "overdue", delivery.reload.status
    assert_equal "overdue", temple.platform_billing_state(failed_at + 8.days)
    assert_equal 1, SystemAuditLog.where(action: "platform_billing.delivery_transition", target: delivery).count

    Billing::PlatformBillingLifecycle.advance!(delivery:, now: failed_at + 7.days)
    assert_equal "grace", delivery.reload.status
    assert_equal "grace", temple.platform_billing_state(failed_at + 7.days)
    Billing::PlatformBillingLifecycle.advance!(delivery:, now: failed_at + 37.days)
    assert_equal "frozen", delivery.reload.status
    assert_equal "frozen", temple.platform_billing_state(failed_at + 37.days)
    assert_equal %w[overdue grace frozen], SystemAuditLog.where(action: "platform_billing.delivery_transition", target: delivery).order(:created_at).map { |log| log.metadata["to"] }
  end

  test "an idempotent event replay does not prevent the independent time advance" do
    temple = create_temple
    delivery = temple.platform_billing_deliveries.create!(kind: "monthly", status: "collecting", currency: "TWD", idempotency_key: "lifecycle-2", provider_reference: "in_1")
    object = Struct.new(:id, :metadata, :customer, keyword_init: true).new(id: "in_1", metadata: { "temple_id" => temple.id.to_s, "delivery_id" => delivery.id.to_s })
    event = Struct.new(:id, :type, :data, keyword_init: true).new(id: "evt_1", type: "invoice.payment_failed", data: Struct.new(:object).new(object))
    failed_at = Time.utc(2026, 8, 1)

    Billing::StripePlatformBillingEventIngest.ingest!(event:, now: failed_at)
    Billing::StripePlatformBillingEventIngest.ingest!(event:, now: failed_at + 8.days)
    PlatformBillingLifecycleJob.perform_now(reference_time: failed_at + 8.days)

    assert_equal 1, PlatformBillingEvent.where(provider_event_id: "evt_1").count
    assert_equal "grace", delivery.reload.status
  end
end
