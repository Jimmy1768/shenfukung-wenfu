require "test_helper"

class AdminPaymentMethodsTest < ActionDispatch::IntegrationTest
  test "owner can view and update payment methods" do
    temple = create_temple
    owner = create_admin_user(temple: temple, role: "owner")

    sign_in_admin(owner)

    get admin_dashboard_path

    assert_response :success
    assert_includes response.body, "帳務設定"

    get admin_payment_methods_path

    assert_response :success
    assert_includes response.body, "ECPay"
    assert_includes response.body, "帳務設定"
    assert_includes response.body, "NT$10,000"
    assert_includes response.body, "一次性開通費"
    assert_includes response.body, "每月自動收取"
    assert_includes response.body, "21 天"
    refute_includes response.body, "年繳"

    assert_difference -> { SystemAuditLog.where(action: "admin.payment_methods.updated").count }, 1 do
      patch admin_payment_methods_path, params: {
        payment_methods: {
          ecpay_merchant_id: "2000132",
          ecpay_hash_key: "hash-key-value",
          ecpay_hash_iv: "hash-iv-value",
          ecpay_environment: "stage"
        }
      }
    end

    assert_redirected_to admin_payment_methods_path
    temple.reload
    assert_equal "2000132", temple.payment_gateway_settings_for(:ecpay)["merchant_id"]
    assert_equal "stage", temple.payment_gateway_settings_for(:ecpay)["environment"]
    refute temple.billing_payment_method_on_file?
  end

  test "stored ecpay secrets do not render back into html" do
    temple = create_temple(
      payment_provider_settings: {
        "ecpay" => {
          "merchant_id" => "2000132",
          "hash_key" => "TempleHashKeySecret",
          "hash_iv" => "TempleHashIvSecret",
          "environment" => "stage"
        }
      }
    )
    owner = create_admin_user(temple: temple, role: "owner")

    sign_in_admin(owner)
    get admin_payment_methods_path

    assert_response :success
    assert_includes response.body, "2000132"
    refute_includes response.body, "TempleHashKeySecret"
    refute_includes response.body, "TempleHashIvSecret"
    assert_includes response.body, "Merchant ID"
    assert_includes response.body, "HashKey"
    assert_includes response.body, "HashIV"
  end

  test "payment method audit log does not persist raw ecpay secrets" do
    temple = create_temple
    owner = create_admin_user(temple: temple, role: "owner")

    sign_in_admin(owner)

    patch admin_payment_methods_path, params: {
      payment_methods: {
        ecpay_merchant_id: "2000132",
        ecpay_hash_key: "hash-key-value",
        ecpay_hash_iv: "hash-iv-value",
        ecpay_environment: "stage"
      }
    }

    log = SystemAuditLog.order(created_at: :desc).find_by!(action: "admin.payment_methods.updated")
    serialized = log.metadata.to_json
    refute_includes serialized, "hash-key-value"
    refute_includes serialized, "hash-iv-value"
    assert_includes Array(log.metadata["changed_fields"]), "ecpay"
  end

  test "temple owner by permission can view and update payment methods" do
    temple = create_temple
    owner = create_admin_user(temple: temple, role: "admin", membership_role: "owner", permission_overrides: { manage_permissions: true })

    sign_in_admin(owner)

    get admin_dashboard_path

    assert_response :success
    assert_includes response.body, "帳務設定"

    get admin_payment_methods_path

    assert_response :success

    patch admin_payment_methods_path, params: {
      payment_methods: {
        ecpay_merchant_id: "2000132",
        ecpay_hash_key: "hash-key-value",
        ecpay_hash_iv: "hash-iv-value",
        ecpay_environment: "stage"
      }
    }

    assert_redirected_to admin_payment_methods_path
  end

  test "updating ECPay preserves legacy billing settings without asserting a method" do
    temple = create_temple
    owner = create_admin_user(temple: temple, role: "owner")

    sign_in_admin(owner)

    patch admin_payment_methods_path, params: {
      payment_methods: {
        ecpay_merchant_id: "2000132",
        ecpay_hash_key: "hash-key-value",
        ecpay_hash_iv: "hash-iv-value",
        ecpay_environment: "stage",
        billing_payment_method_on_file: "0"
      }
    }

    assert_redirected_to admin_payment_methods_path
    temple.reload
    refute temple.billing_payment_method_on_file?
    assert_nil temple.billing_grace_started_at
  end

  test "owner can start Stripe billing setup" do
    temple = create_temple
    owner = create_admin_user(temple: temple, role: "owner")
    result = Billing::StripePaymentMethodSetup::Result.new(
      session_id: "cs_setup_123",
      url: "https://checkout.stripe.com/c/cs_setup_123"
    )

    sign_in_admin(owner)

    Billing::StripePaymentMethodSetup.stub(:start, ->(**_args) { result }) do
      post start_billing_setup_admin_payment_methods_path
    end

    assert_redirected_to result.url
  end

  test "owner can complete Stripe billing setup return" do
    temple = create_temple
    owner = create_admin_user(temple: temple, role: "owner")
    completed_session_id = nil

    sign_in_admin(owner)

    Billing::StripePaymentMethodSetup.stub(:complete, ->(**args) { completed_session_id = args[:checkout_session_id] }) do
      get billing_setup_return_admin_payment_methods_path(checkout_session_id: "cs_setup_123")
    end

    assert_equal "cs_setup_123", completed_session_id
    assert_redirected_to admin_payment_methods_path
  end

  test "setup incomplete does not start grace period" do
    temple = create_temple
    owner = create_admin_user(temple: temple, role: "owner")

    sign_in_admin(owner)

    patch admin_payment_methods_path, params: {
      payment_methods: {
        ecpay_merchant_id: "",
        ecpay_hash_key: "",
        ecpay_hash_iv: "",
        ecpay_environment: "stage"
      }
    }

    assert_redirected_to admin_payment_methods_path
    temple.reload
    assert_nil temple.billing_grace_started_at
    refute temple.online_payments_frozen?
  end

  test "payment methods display the persisted overdue platform billing state" do
    temple = create_temple(payment_provider_settings: {
      "ecpay" => { "merchant_id" => "2000132", "hash_key" => "key", "hash_iv" => "iv", "environment" => "stage" },
      "billing" => { "stripe_payment_method_id" => "pm_1" }
    })
    temple.platform_billing_deliveries.create!(kind: "monthly", status: "overdue", currency: "TWD", idempotency_key: "overdue-display",
      due_at: 1.day.from_now, grace_deadline_at: 31.days.from_now)
    owner = create_admin_user(temple: temple, role: "owner")

    sign_in_admin(owner)
    get admin_payment_methods_path

    assert_response :success
    assert_includes response.body, "帳務逾期"
    refute_includes response.body, "寬限期剩餘 30 天"
  end

  test "grace period countdown reflects the real delivery deadline, not the legacy 30-day default" do
    temple = create_temple(payment_provider_settings: {
      "ecpay" => { "merchant_id" => "2000132", "hash_key" => "key", "hash_iv" => "iv", "environment" => "stage" },
      "billing" => { "stripe_payment_method_id" => "pm_1" }
    })
    temple.platform_billing_deliveries.create!(kind: "monthly", status: "grace", currency: "TWD", idempotency_key: "grace-display",
      due_at: 5.days.ago, grace_deadline_at: 6.days.from_now)
    owner = create_admin_user(temple: temple, role: "owner")

    sign_in_admin(owner)
    get admin_payment_methods_path

    assert_response :success
    # 6 days from now rounds up to 6 (ceil), not the legacy default of 30
    # and not the static 21-day policy figure shown elsewhere on the page.
    assert_includes response.body, "寬限期剩餘 6 天"
    refute_includes response.body, "寬限期剩餘 30 天"
    refute_includes response.body, "寬限期剩餘 21 天"
  end

  test "usage tier pricing is shown on the payment method tab" do
    temple = create_temple
    owner = create_admin_user(temple: temple, role: "owner")

    sign_in_admin(owner)
    get admin_payment_methods_path

    assert_response :success
    assert_includes response.body, "使用量階梯定價"
    assert_includes response.body, "前 500 筆報名"
    assert_includes response.body, "第 501–2,000 筆報名"
    assert_includes response.body, "第 2,001–10,000 筆報名"
    assert_includes response.body, "第 10,001 筆以上"
    assert_includes response.body, "NT$1.00"
    assert_includes response.body, "NT$1.25"
    assert_includes response.body, "NT$1.50"
    assert_includes response.body, admin_platform_billing_path
  end

  test "payment methods presentation follows the entitlement state before historical Stripe settings" do
    temple = create_temple(payment_provider_settings: {
      "ecpay" => { "merchant_id" => "2000132", "hash_key" => "key", "hash_iv" => "iv", "environment" => "stage" },
      "billing" => { "stripe_payment_method_id" => "pm_historical" }
    })
    entitlement = temple.adopt_platform_billing_entitlement!
    owner = create_admin_user(temple: temple, role: "owner")
    form = Admin::PaymentMethodsForm.new(temple:, params: {
      ecpay_merchant_id: "2000132", ecpay_hash_key: "key", ecpay_hash_iv: "iv", ecpay_environment: "stage"
    })

    assert_equal :setup_needed, form.online_payments_state

    sign_in_admin(owner)
    get admin_payment_methods_path

    assert_response :success
    assert_includes response.body, "ECPay 尚未設定完成"

    entitlement.update!(state: "suspended")
    assert_equal :frozen, form.online_payments_state
    get admin_payment_methods_path

    assert_response :success
    assert_includes response.body, "已凍結"
  end

  test "billing copy is localized without annual billing claims" do
    copy = {
      subtitle: "admin.payment_methods.sections.payment_method.subtitle",
      price_title: "admin.payment_methods.sections.payment_method.notes.price_title",
      price_body: "admin.payment_methods.sections.payment_method.notes.price_body",
      freeze_body: "admin.payment_methods.sections.payment_method.notes.freeze_body",
      onboarding_fee: "admin.payment_methods.status.onboarding_fee"
    }

    %i[en zh-TW].each do |locale|
      rendered = [
        I18n.t(copy[:subtitle], locale:, monthly_amount: "NT$1,500", onboarding_amount: "NT$10,000"),
        I18n.t(copy[:price_title], locale:, onboarding_amount: "NT$10,000"),
        I18n.t(copy[:price_body], locale:, monthly_amount: "NT$1,500"),
        I18n.t(copy[:freeze_body], locale:, days: 30),
        I18n.t(copy[:onboarding_fee], locale:)
      ].join(" ")

      assert_includes rendered, "NT$10,000"
      assert_includes rendered, "NT$1,500"
      assert_includes rendered, "30"
      refute_match(/annual|yearly|年繳/i, rendered)
    end
  end

  test "non-owner is redirected away from payment methods" do
    temple = create_temple
    admin = create_admin_user(temple: temple, role: "admin")

    sign_in_admin(admin)

    get admin_dashboard_path

    assert_response :success
    refute_includes response.body, "帳務設定"

    get admin_payment_methods_path

    assert_redirected_to admin_dashboard_path
  end
end
