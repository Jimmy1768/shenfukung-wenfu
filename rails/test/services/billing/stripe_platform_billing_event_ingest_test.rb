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
end
