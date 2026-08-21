require "test_helper"

class PlatformBillingMonthlyCollectionJobTest < ActiveSupport::TestCase
  setup do
    @reference_time = Time.current
    @current_period_start_at = Billing::PlatformUsage.period_start_at_for(
      Billing::PlatformUsage.previous_month(@reference_time)
    )
    @prior_period_start_at = Billing::PlatformUsage.period_start_at_for(
      Billing::PlatformUsage.previous_month(@current_period_start_at)
    )
  end

  test "dispatches a pending monthly delivery for the exact period reference_time resolves to" do
    temple = create_temple
    delivery = temple.platform_billing_deliveries.create!(kind: "monthly", status: "pending", currency: "TWD",
      idempotency_key: "collection-1", period_start_at: @current_period_start_at)
    dispatched = []

    Billing::PlatformBillingCollectionDispatcher.stub(:dispatch!, ->(delivery:) { dispatched << delivery }) do
      PlatformBillingMonthlyCollectionJob.perform_now(reference_time: @reference_time)
    end

    assert_equal [delivery], dispatched
  end

  test "does not collect a pending delivery from an earlier period -- the backlog case" do
    temple = create_temple
    stale_delivery = temple.platform_billing_deliveries.create!(kind: "monthly", status: "pending", currency: "TWD",
      idempotency_key: "collection-stale", period_start_at: @prior_period_start_at)
    dispatched = []

    Billing::PlatformBillingCollectionDispatcher.stub(:dispatch!, ->(delivery:) { dispatched << delivery }) do
      PlatformBillingMonthlyCollectionJob.perform_now(reference_time: @reference_time)
    end

    assert_empty dispatched
    assert_equal "pending", stale_delivery.reload.status
  end

  test "does not touch a delivery that is not a pending monthly delivery for the period" do
    temple = create_temple
    temple.platform_billing_deliveries.create!(kind: "setup", status: "pending", currency: "TWD",
      idempotency_key: "collection-setup", period_start_at: @current_period_start_at)
    temple.platform_billing_deliveries.create!(kind: "monthly", status: "collecting", currency: "TWD",
      idempotency_key: "collection-already-collecting", period_start_at: @current_period_start_at)
    dispatched = []

    Billing::PlatformBillingCollectionDispatcher.stub(:dispatch!, ->(delivery:) { dispatched << delivery }) do
      PlatformBillingMonthlyCollectionJob.perform_now(reference_time: @reference_time)
    end

    assert_empty dispatched
  end

  test "one delivery's collection failure does not prevent another delivery's dispatch" do
    failed_temple = create_temple
    successful_temple = create_temple
    failed_delivery = failed_temple.platform_billing_deliveries.create!(kind: "monthly", status: "pending", currency: "TWD",
      idempotency_key: "collection-failed", period_start_at: @current_period_start_at)
    successful_delivery = successful_temple.platform_billing_deliveries.create!(kind: "monthly", status: "pending", currency: "TWD",
      idempotency_key: "collection-success", period_start_at: @current_period_start_at)

    Billing::PlatformBillingCollectionDispatcher.stub(:dispatch!, ->(delivery:) do
      raise "dispatcher unavailable" if delivery == failed_delivery

      delivery.update!(status: "collecting")
    end) do
      PlatformBillingMonthlyCollectionJob.perform_now(reference_time: @reference_time)
    end

    assert_equal "pending", failed_delivery.reload.status
    assert_equal "collecting", successful_delivery.reload.status
    assert_equal 1, SystemAuditLog.where(action: "platform_billing.monthly_collection_failed", target: failed_delivery).count
  end
end
