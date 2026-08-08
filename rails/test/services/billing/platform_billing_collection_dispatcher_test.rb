# frozen_string_literal: true

require "test_helper"

class Billing::PlatformBillingCollectionDispatcherTest < ActiveSupport::TestCase
  test "collects one pending delivery once and skips its collecting retry" do
    delivery = monthly_delivery
    attempts = 0

    Billing::StripePlatformBillingCollection.stub(:collect!, ->(delivery:) do
      attempts += 1
      delivery.update!(status: "collecting")
    end) do
      Billing::PlatformBillingCollectionDispatcher.dispatch!(delivery:)
      Billing::PlatformBillingCollectionDispatcher.dispatch!(delivery: delivery.reload)
    end

    assert_equal 1, attempts
    assert_equal "collecting", delivery.reload.status
  end

  test "records missing collection prerequisites without changing a pending delivery" do
    delivery = monthly_delivery

    Billing::PlatformBillingCollectionDispatcher.dispatch!(delivery:)

    assert_equal "pending", delivery.reload.status
    audit = SystemAuditLog.find_by!(action: "platform_billing.collection_failed", target: delivery)
    assert_equal ["delivery_id", "error_class", "message"], audit.metadata.keys.sort
    assert_equal delivery.id, audit.metadata["delivery_id"]
    assert_equal "ArgumentError", audit.metadata["error_class"]
    assert_operator audit.metadata["message"].length, :<=, 200
  end

  test "records collector errors without changing a pending delivery" do
    delivery = monthly_delivery

    Billing::StripePlatformBillingCollection.stub(:collect!, ->(delivery:) { raise RuntimeError, "collector unavailable" }) do
      Billing::PlatformBillingCollectionDispatcher.dispatch!(delivery:)
    end

    assert_equal "pending", delivery.reload.status
    audit = SystemAuditLog.find_by!(action: "platform_billing.collection_failed", target: delivery)
    assert_equal "RuntimeError", audit.metadata["error_class"]
    assert_equal "collector unavailable", audit.metadata["message"]
  end

  private

  def monthly_delivery
    create_temple.platform_billing_deliveries.create!(kind: "monthly", status: "pending", currency: "TWD",
      idempotency_key: "dispatch-#{SecureRandom.hex(4)}")
  end
end
