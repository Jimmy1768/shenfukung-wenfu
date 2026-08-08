require "test_helper"

class Api::V1::PlatformBillingWebhooksTest < ActionDispatch::IntegrationTest
  Event = Struct.new(:id, :type, :data, keyword_init: true)
  Object = Struct.new(:id, :metadata, :customer, :card, keyword_init: true)

  test "accepts a valid signed event and makes replay idempotent without raw evidence" do
    temple = create_temple
    entitlement = temple.adopt_platform_billing_entitlement!
    delivery = create_delivery(temple)
    event = platform_event("evt_signed", delivery)

    with_signed_event(event) do
      post_webhook(signature: "t=1,v1=valid")
      assert_response :success
      post_webhook(signature: "t=1,v1=valid")
      assert_response :success
    end

    assert_equal "paid", delivery.reload.status
    assert_equal "active", entitlement.reload.state
    assert_equal 1, PlatformBillingEvent.where(provider_event_id: "evt_signed").count
    evidence = PlatformBillingEvent.find_by!(provider_event_id: "evt_signed").payload.to_json
    refute_includes evidence, "4242"
    refute_includes evidence, "valid"
  end

  test "rejects unsigned and bad-signature requests" do
    with_webhook_secret do
      post_webhook
      assert_response :unauthorized
      Stripe::Webhook.stub(:construct_event, ->(*) { raise Stripe::SignatureVerificationError, "bad signature" }) do
        post_webhook(signature: "bad")
      end
      assert_response :unauthorized
    end
  end

  test "rejects a delivery from another temple without changing either billing status" do
    temple = create_temple
    other_temple = create_temple
    entitlement = temple.adopt_platform_billing_entitlement!
    other_entitlement = other_temple.adopt_platform_billing_entitlement!
    delivery = create_delivery(temple)
    other_delivery = create_delivery(other_temple)
    event = platform_event("evt_mismatch", delivery, temple_id: other_temple.id, delivery_id: delivery.id)

    with_signed_event(event) { post_webhook(signature: "t=1,v1=valid") }

    assert_response :unprocessable_entity
    assert_equal "collecting", delivery.reload.status
    assert_equal "collecting", other_delivery.reload.status
    assert_equal "pending_setup", entitlement.reload.state
    assert_equal "pending_setup", other_entitlement.reload.state
    assert_equal 0, PlatformBillingEvent.where(provider_event_id: "evt_mismatch").count
  end

  private

  def create_delivery(temple)
    temple.platform_billing_deliveries.create!(kind: "monthly", status: "collecting", currency: "TWD", idempotency_key: "delivery-#{temple.id}", provider_reference: "in_#{temple.id}")
  end

  def platform_event(id, delivery, temple_id: delivery.temple_id, delivery_id: delivery.id)
    object = Object.new(id: delivery.provider_reference, metadata: { "temple_id" => temple_id.to_s, "delivery_id" => delivery_id.to_s, "purpose" => "templemate_platform_monthly" }, customer: "cus_safe", card: { number: "4242424242424242" })
    Event.new(id:, type: "invoice.paid", data: Struct.new(:object).new(object))
  end

  def with_signed_event(event)
    with_webhook_secret do
      Stripe::Webhook.stub(:construct_event, ->(body, signature, secret) { assert_equal "{}", body; assert_equal "t=1,v1=valid", signature; assert_equal "whsec_fixture", secret; event }) { yield }
    end
  end

  def with_webhook_secret
    config = Rails.configuration.x.stripe
    original = config.platform_webhook_secret
    config.platform_webhook_secret = "whsec_fixture"
    yield
  ensure
    config.platform_webhook_secret = original
  end

  def post_webhook(signature: nil)
    headers = { "CONTENT_TYPE" => "application/json" }
    headers["Stripe-Signature"] = signature if signature
    post api_v1_platform_billing_webhook_path, params: "{}", headers:
  end
end
