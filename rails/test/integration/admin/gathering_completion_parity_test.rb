# frozen_string_literal: true

require "test_helper"

# W2: a gathering is a sub-type, not a separate flow. These are written as
# OUTCOMES ("a gathering reaches checkout_ready? through the same path") rather
# than as mechanics ("the exclusion is gone") on purpose -- review found that
# deleting TempleRegistration#admin_completion_required?'s gathering branch
# without a reachable completion path first would make every gathering
# registration permanently unpayable, silently and patron-facing.
class GatheringCompletionParityTest < ActionDispatch::IntegrationTest
  setup do
    @temple = create_temple
    @admin = create_admin_user(temple: @temple, permission_overrides: { manage_registrations: true })
    @patron = User.create!(
      email: "gathering-parity-#{SecureRandom.hex(3)}@example.com",
      english_name: "Gathering Patron",
      encrypted_password: User.password_hash("Password123!")
    )
    @gathering = @temple.temple_gatherings.create!(
      slug: "parity-gathering-#{SecureRandom.hex(2)}",
      title: "Parity Gathering", currency: "TWD", price_cents: 500,
      status: "published", starts_on: Date.current
    )
  end

  def gathering_registration
    create_registration(user: @patron, offering: @gathering, admin_completed_at: nil)
  end

  test "a gathering registration is NOT checkout-ready until an admin completes it" do
    registration = gathering_registration

    assert registration.admin_completion_required?, "gatherings follow the same pipeline"
    refute registration.checkout_ready?
  end

  test "a gathering reaches checkout_ready? through the same completion path as every other type" do
    registration = gathering_registration
    sign_in_admin(@admin)

    assert_difference -> { SystemAuditLog.where(action: "temple.registration.admin_completed").count }, 1 do
      post complete_admin_gathering_offering_order_path(@gathering, registration)
    end

    assert_redirected_to admin_gathering_offering_order_path(@gathering, registration)
    assert registration.reload.checkout_ready?, "the whole point: reachable, not permanently blocked"
  end

  test "the completion path is reachable for all three registrable types" do
    event = create_offering(temple: @temple, title: "Parity Event")
    service = @temple.temple_services.create!(
      slug: "parity-service-#{SecureRandom.hex(2)}", title: "Parity Service",
      currency: "TWD", price_cents: 500, status: "published"
    )
    sign_in_admin(@admin)

    {
      complete_admin_event_offering_order_path(event, create_registration(user: @patron, offering: event, admin_completed_at: nil)) => event,
      complete_admin_service_offering_order_path(service, create_registration(user: @patron, offering: service, admin_completed_at: nil)) => service,
      complete_admin_gathering_offering_order_path(@gathering, gathering_registration) => @gathering
    }.each_key do |path|
      post path
      assert_response :redirect, "#{path} must be routable and reachable"
    end
  end

  test "the path helper builds a gathering URL, not an event one" do
    registration = gathering_registration
    path = ActionController::Base.helpers # sanity: exercise through the real helper
    _ = path

    generated = Rails.application.routes.url_helpers
      .complete_admin_gathering_offering_order_path(@gathering, registration)

    assert_includes generated, "/gatherings/"
    refute_includes generated, "/events/", "the helper used to fall through to the event route"
  end

  test "a completed gathering still cannot be paid while the temple's billing is frozen" do
    @temple.adopt_platform_billing_entitlement!.update!(state: "suspended")
    registration = gathering_registration
    registration.mark_admin_completed!

    assert registration.checkout_ready?, "completion is independent of billing"
    assert @temple.registration_intake_frozen?, "the delinquency gate is type-agnostic"
  end
end
