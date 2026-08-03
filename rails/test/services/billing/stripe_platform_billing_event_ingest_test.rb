require "test_helper"
class Billing::StripePlatformBillingEventIngestTest < ActiveSupport::TestCase
  Object = Struct.new(:id, :metadata, :customer, keyword_init: true)
  Event = Struct.new(:id, :type, :data, keyword_init: true)
  test "records failure once and advances overdue to frozen deterministically" do
    temple = create_temple
    delivery = temple.platform_billing_deliveries.create!(kind: "monthly", status: "collecting", currency: "TWD", idempotency_key: "d1", provider_reference: "in_1")
    object = Object.new(id: "in_1", metadata: { "temple_id" => temple.id.to_s, "delivery_id" => delivery.id.to_s })
    event = Event.new(id: "evt_1", type: "invoice.payment_failed", data: Struct.new(:object).new(object))
    Billing::StripePlatformBillingEventIngest.ingest!(event:, now: Time.utc(2026, 8, 1))
    assert_equal "overdue", delivery.reload.status
    Billing::StripePlatformBillingEventIngest.ingest!(event:, now: Time.utc(2026, 9, 1))
    assert_equal 1, PlatformBillingEvent.count
  end

  test "delegates successful and failed events to the shared lifecycle audit transition" do
    temple = create_temple
    paid_delivery = temple.platform_billing_deliveries.create!(kind: "monthly", status: "collecting", currency: "TWD", idempotency_key: "paid", provider_reference: "in_paid")
    failed_delivery = temple.platform_billing_deliveries.create!(kind: "monthly", status: "collecting", currency: "TWD", idempotency_key: "failed", provider_reference: "in_failed")
    paid_event = event_for(id: "evt_paid", type: "invoice.paid", delivery: paid_delivery)
    failed_event = event_for(id: "evt_failed", type: "invoice.payment_failed", delivery: failed_delivery)
    reference_time = Time.utc(2026, 8, 1)

    Billing::StripePlatformBillingEventIngest.ingest!(event: paid_event, now: reference_time)
    Billing::StripePlatformBillingEventIngest.ingest!(event: failed_event, now: reference_time)
    Billing::StripePlatformBillingEventIngest.ingest!(event: paid_event, now: reference_time + 1.day)

    assert_equal "paid", paid_delivery.reload.status
    assert_equal "overdue", failed_delivery.reload.status
    assert_equal 2, SystemAuditLog.where(action: "platform_billing.delivery_transition").count
    [paid_delivery, failed_delivery].each do |delivery|
      metadata = SystemAuditLog.find_by!(action: "platform_billing.delivery_transition", target: delivery).metadata
      assert_equal %w[delivery_id from reference_time to], metadata.keys.sort
      assert_equal delivery.id, metadata["delivery_id"]
      assert_equal "collecting", metadata["from"]
      assert_equal reference_time.iso8601, metadata["reference_time"]
    end
  end

  private

  def event_for(id:, type:, delivery:)
    object = Object.new(id: delivery.provider_reference, metadata: { "temple_id" => delivery.temple_id.to_s, "delivery_id" => delivery.id.to_s })
    Event.new(id:, type:, data: Struct.new(:object).new(object))
  end
end
