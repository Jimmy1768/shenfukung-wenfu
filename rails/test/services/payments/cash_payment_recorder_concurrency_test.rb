# frozen_string_literal: true

require "test_helper"

module Payments
  class CashPaymentRecorderConcurrencyTest < ActiveSupport::TestCase
    self.use_transactional_tests = false

    def teardown
      SystemAuditLog.where(temple: @temple).delete_all if @temple
      TemplePayment.where(temple: @temple).delete_all if @temple
      FinancialLedgerEntry.where(external_reference: @registration&.reference_code).delete_all if @registration
      @registration&.destroy!
      @offering&.destroy!
      AdminPermission.where(admin_account: @admin&.admin_account, temple: @temple).delete_all if @admin && @temple
      AdminTempleMembership.where(admin_account: @admin&.admin_account, temple: @temple).delete_all if @admin && @temple
      @admin&.admin_account&.destroy!
      @admin&.destroy!
      @user&.destroy!
      @temple&.destroy!
    end

    test "two database connections produce one cash settlement and one rejected duplicate" do
      @temple = create_temple
      @offering = create_offering(temple: @temple, price_cents: 500)
      @user = User.create!(email: "cash-concurrency-#{SecureRandom.hex(4)}@example.com", english_name: "Cash Concurrency", encrypted_password: User.password_hash("Password123!"))
      @registration = create_registration(user: @user, offering: @offering)
      @admin = create_admin_user(temple: @temple)
      AdminPermission.find_by!(admin_account: @admin.admin_account, temple: @temple).update!(record_cash_payments: true)

      start = Queue.new
      outcomes = Queue.new
      workers = 2.times.map do
        Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            start.pop
            payment = CashPaymentRecorder.new(registration: @registration, admin_user: @admin, amount_cents: 500, currency: "TWD").record!
            outcomes << [:completed, payment.id]
          rescue CashPaymentRecorder::SettlementError
            outcomes << [:duplicate]
          end
        end
      end

      2.times { start << true }
      workers.each(&:join)

      results = 2.times.map { outcomes.pop }
      assert_equal 1, results.count { |outcome| outcome.first == :completed }
      assert_equal 1, results.count { |outcome| outcome.first == :duplicate }
      assert_equal 1, @registration.reload.temple_payments.where(provider: "manual_cash", status: "completed").count
      assert_equal 1, FinancialLedgerEntry.where(external_reference: @registration.reference_code).count
      assert_equal 1, SystemAuditLog.where(action: "temple.payment.cash_recorded", temple: @temple).count
      assert_equal TempleRegistration::PAYMENT_STATUSES[:paid], @registration.reload.payment_status
    end
  end
end
