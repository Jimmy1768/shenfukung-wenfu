require "test_helper"

module Registrations
  class AdminCompletionGateTest < ActionDispatch::IntegrationTest
    test "patron self-registration blocks online checkout until an admin marks it complete, end to end" do
      temple = create_temple(payment_provider_settings: { "patron_checkout_provider" => "fake" })
      offering = create_offering(temple:, slug: "completion-gate-offering", title: "Completion Gate Offering", price_cents: 900)
      patron = User.create!(email: "gate-patron@example.test", english_name: "Gate Patron", encrypted_password: User.password_hash("Password123!"))

      sign_in_account(patron, temple_slug: temple.slug)
      post account_registrations_path, params: {
        offering: offering.slug,
        account_action: "event",
        account_registration_intake_form: { contact_name: "Gate Patron", quantity: 1 }
      }
      registration = TempleEventRegistration.order(:created_at).last
      refute registration.admin_completed?

      get payment_account_registration_path(registration)
      assert_response :success
      refute_includes response.body, "前往付款"
      # Deliberately vague: the patron cannot act in this state, so the copy
    # does not narrate the temple's internal step (or its billing).
    assert_includes response.body, "已收到您的報名，廟方正在處理中。"

      assert_no_difference -> { registration.temple_payments.count } do
        post start_checkout_account_registration_path(registration)
      end
      assert_redirected_to payment_account_registration_path(registration)
      follow_redirect!
      assert_includes response.body, I18n.t("account.registrations.payment.awaiting_admin_completion")

      admin_user = create_admin_user(temple:, permission_overrides: { manage_registrations: true })

      sign_in_admin(admin_user)
      refute registration.reload.admin_completed?
      post complete_admin_event_offering_order_path(offering, registration)
      assert_redirected_to admin_event_offering_order_path(offering, registration)
      assert registration.reload.admin_completed?

      sign_in_account(patron, temple_slug: temple.slug)
      get payment_account_registration_path(registration)
      assert_response :success
      assert_includes response.body, "前往付款"

      assert_difference -> { registration.temple_payments.count }, 1 do
        post start_checkout_account_registration_path(registration)
      end
    end

    test "marking complete is audited and does not retroactively change an already-completed timestamp" do
      temple = create_temple
      offering = create_offering(temple:, slug: "completion-audit-offering", title: "Completion Audit Offering", price_cents: 500)
      patron = User.create!(email: "gate-audit-patron@example.test", english_name: "Gate Audit Patron", encrypted_password: User.password_hash("Password123!"))
      registration = create_registration(user: patron, offering:, admin_completed_at: nil)
      admin_user = create_admin_user(temple:, permission_overrides: { manage_registrations: true })

      sign_in_admin(admin_user)
      assert_difference -> { SystemAuditLog.where(action: "temple.registration.admin_completed").count }, 1 do
        post complete_admin_event_offering_order_path(offering, registration)
      end
      first_timestamp = registration.reload.admin_completed_at
      assert_not_nil first_timestamp

      assert_no_difference -> { SystemAuditLog.where(action: "temple.registration.admin_completed").count } do
        travel 1.hour do
          post complete_admin_event_offering_order_path(offering, registration)
        end
      end
      assert_equal first_timestamp, registration.reload.admin_completed_at
    end

    test "admin cash acceptance is not gated by admin completion, matching the Director's explicit scope decision" do
      temple = create_temple
      offering = create_offering(temple:, slug: "cash-not-gated-offering", title: "Cash Not Gated Offering", price_cents: 500)
      patron = User.create!(email: "cash-not-gated@example.test", english_name: "Cash Not Gated", encrypted_password: User.password_hash("Password123!"))
      registration = create_registration(user: patron, offering:, admin_completed_at: nil)
      admin_user = create_admin_user(temple:, permission_overrides: { manage_registrations: true, record_cash_payments: true })

      refute registration.admin_completed?

      sign_in_admin(admin_user)
      assert_difference -> { registration.temple_payments.count }, 1 do
        post admin_payments_path, params: {
          registration_id: registration.id,
          temple_payment: { amount_cents: registration.total_price_cents, currency: registration.currency }
        }
      end
      assert_equal TempleRegistration::PAYMENT_STATUSES[:paid], registration.reload.payment_status
      refute registration.admin_completed?
    end

    test "gathering checkout is gated like every other type, and completion opens it" do
      temple = create_temple
      gathering = temple.temple_gatherings.create!(
        slug: "completion-gate-gathering-checkout",
        title: "Completion Gate Gathering Checkout",
        currency: "TWD",
        price_cents: 450,
        status: "published",
        starts_on: Date.current
      )
      patron = User.create!(email: "gate-gathering-patron@example.test", english_name: "Gate Gathering Patron", encrypted_password: User.password_hash("Password123!"))

      sign_in_account(patron, temple_slug: temple.slug)
      post account_registrations_path, params: {
        offering: gathering.slug,
        account_action: "gathering",
        account_registration_intake_form: { contact_name: "Gate Gathering Patron", quantity: 1 }
      }
      registration = TempleEventRegistration.order(:created_at).last
      refute registration.admin_completed?
      refute registration.checkout_ready?, "gatherings follow the same pipeline now"

      get payment_account_registration_path(registration)
      assert_response :success
      refute_includes response.body, "前往付款", "not payable until the temple reviews it"

      # ...and the completion path is reachable, so this is a wait, not a wall.
      registration.mark_admin_completed!
      get payment_account_registration_path(registration)
      assert_response :success
      assert_includes response.body, "前往付款"
    end

    test "the three non-actionable states are indistinguishable to the patron" do
      # W2: be vague wherever the patron has nothing to do; specific only
      # where they can act. Narrating internal state leaks the temple's
      # billing problem and can be flatly wrong (a patron who paid cash
      # during a freeze still reads "unpaid").
      vague = I18n.t("account.registrations.payment.awaiting_admin_completion_notice", locale: :"zh-TW")

      assert_equal vague, I18n.t("account.registrations.payment.online_payments_frozen_notice", locale: :"zh-TW")
      assert_equal vague, I18n.t("account.registrations.payment.online_payments_frozen", locale: :"zh-TW")
      refute_includes vague, "帳務", "must not reveal the temple's billing state"
      refute_includes vague, "付款開放", "must not hint at a payment problem"
      refute_includes vague, "確認完成後", "must not narrate the admin's internal step"
    end

  end
end
