require "test_helper"

module Payments
  class CashPaymentRecorderTest < ActiveSupport::TestCase
    test "records ledger entry and payment" do
      temple = create_temple
      offering = TempleOffering.create!(
        temple:,
        slug: "lamp",
        title: "Lamp",
        currency: "TWD",
        price_cents: 500,
        starts_on: Date.current,
        ends_on: Date.current + 1.day
      )
      registration = TempleEventRegistration.create!(
        temple:,
        registrable: offering,
        quantity: 1,
        contact_payload: {},
        logistics_payload: {},
        metadata: {}
      )
      admin = create_admin_user(temple:)
      AdminPermission.find_by!(admin_account: admin.admin_account, temple:).update!(record_cash_payments: true)

      recorder = CashPaymentRecorder.new(
        registration:,
        admin_user: admin,
        amount_cents: "500",
        currency: "TWD",
        notes: "Cash at desk"
      )

      payment = nil
      assert_difference -> { FinancialLedgerEntry.count }, 1 do
        payment = recorder.record!
      end

      assert_equal TemplePayment::STATUSES[:completed], payment.status
      assert_equal TemplePayment::PAYMENT_METHODS[:cash], payment.payment_method
      assert_equal "Cash at desk", payment.payment_payload["notes"]
      ledger_entry = FinancialLedgerEntry.find_by!(external_reference: registration.reference_code)
      assert_equal registration.id, ledger_entry.details["registration_id"]
      assert_equal 5, ledger_entry.amount.to_i
      assert_equal admin.admin_account.id, ledger_entry.metadata["recorded_by_admin_id"]
      assert_equal TempleEventRegistration::PAYMENT_STATUSES[:paid], registration.reload.payment_status
    end

    test "rejects wrong values, ineligible registrations, and missing permission before creating retained evidence" do
      temple = create_temple
      offering = create_offering(temple:, price_cents: 500)
      user = User.create!(email: "cash-recorder-guard@example.com", english_name: "Cash Guard", encrypted_password: User.password_hash("Password123!"))
      registration = create_registration(user:, offering:)
      admin = create_admin_user(temple:)

      assert_no_difference ["TemplePayment.count", "FinancialLedgerEntry.count", "SystemAuditLog.count"] do
        assert_raises(CashPaymentRecorder::SettlementError) do
          CashPaymentRecorder.new(registration:, admin_user: admin, amount_cents: 400, currency: "USD").record!
        end
      end

      AdminPermission.find_by!(admin_account: admin.admin_account, temple:).update!(record_cash_payments: true)
      registration.update!(fulfillment_status: TempleRegistration::FULFILLMENT_STATUSES[:cancelled])
      assert_no_difference ["TemplePayment.count", "FinancialLedgerEntry.count", "SystemAuditLog.count"] do
        assert_raises(CashPaymentRecorder::SettlementError) do
          CashPaymentRecorder.new(registration:, admin_user: admin, amount_cents: 500, currency: "TWD").record!
        end
      end
    end

    test "rejects cash settlement while the temple's billing is frozen, same as online checkout" do
      temple = create_temple
      offering = create_offering(temple:, price_cents: 500)
      user = User.create!(email: "cash-recorder-frozen@example.com", english_name: "Cash Frozen", encrypted_password: User.password_hash("Password123!"))
      registration = create_registration(user:, offering:)
      admin = create_admin_user(temple:)
      AdminPermission.find_by!(admin_account: admin.admin_account, temple:).update!(record_cash_payments: true)
      temple.adopt_platform_billing_entitlement!.update!(state: "suspended")

      assert_no_difference ["TemplePayment.count", "FinancialLedgerEntry.count", "SystemAuditLog.count"] do
        assert_raises(CashPaymentRecorder::SettlementError) do
          CashPaymentRecorder.new(registration:, admin_user: admin, amount_cents: 500, currency: "TWD").record!
        end
      end
      assert_equal TempleRegistration::PAYMENT_STATUSES[:pending], registration.reload.payment_status
    end

    test "rejects malformed, fractional, and missing amount input before creating retained evidence" do
      temple = create_temple
      offering = create_offering(temple:, price_cents: 500)
      user = User.create!(email: "cash-recorder-amount-guard@example.com", english_name: "Cash Amount Guard", encrypted_password: User.password_hash("Password123!"))
      registration = create_registration(user:, offering:)
      admin = create_admin_user(temple:)
      AdminPermission.find_by!(admin_account: admin.admin_account, temple:).update!(record_cash_payments: true)

      ["500junk", "500.0", "", nil, 500.0].each do |invalid_amount|
        assert_no_difference ["TemplePayment.count", "FinancialLedgerEntry.count", "SystemAuditLog.count", "PlatformBillingStatement.count", "PlatformBillingUsageRecord.count", "PlatformBillingAdjustment.count"] do
          assert_raises(CashPaymentRecorder::SettlementError) do
            CashPaymentRecorder.new(registration:, admin_user: admin, amount_cents: invalid_amount, currency: "TWD").record!
          end
        end

        assert_equal TempleRegistration::PAYMENT_STATUSES[:pending], registration.reload.payment_status
      end
    end

    test "completed cash settlement qualifies once at its persisted completion timestamp and duplicates fail closed" do
      temple = create_temple
      offering = create_offering(temple:, price_cents: 500)
      user = User.create!(email: "cash-recorder-qualified@example.com", english_name: "Cash Qualified", encrypted_password: User.password_hash("Password123!"))
      registration = create_registration(user:, offering:)
      admin = create_admin_user(temple:)
      AdminPermission.find_by!(admin_account: admin.admin_account, temple:).update!(record_cash_payments: true)

      payment = CashPaymentRecorder.new(registration:, admin_user: admin, amount_cents: 500, currency: "TWD").record!
      qualifying = Billing::PlatformUsage.qualifying_registrations(temple:).find { |entry| entry.registration.id == registration.id }

      assert_equal "completed_cash", qualifying.qualification_source
      assert_equal payment.reload.processed_at.to_i, qualifying.qualifying_at.to_i
      assert_no_difference ["TemplePayment.count", "FinancialLedgerEntry.count", "SystemAuditLog.count"] do
        assert_raises(CashPaymentRecorder::SettlementError) do
          CashPaymentRecorder.new(registration:, admin_user: admin, amount_cents: 500, currency: "TWD").record!
        end
      end
    end
  end
end
