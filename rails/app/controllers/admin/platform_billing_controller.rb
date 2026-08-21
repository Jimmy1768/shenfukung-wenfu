# frozen_string_literal: true

module Admin
  class PlatformBillingController < BaseController
    before_action :require_owner_admin!

    def show
      @current_usage = Billing::PlatformUsage.for_month(temple: current_temple)
      @statements = current_temple.platform_billing_statements
        .includes(:platform_billing_adjustments, :platform_billing_delivery)
        .order(period_start_at: :desc)
    end

    private

    def require_owner_admin!
      return if owner_admin_for_current_temple?

      redirect_to admin_dashboard_path, alert: "Only the temple owner can view platform billing."
    end
  end
end
