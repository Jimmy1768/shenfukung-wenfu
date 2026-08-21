# frozen_string_literal: true

module AdminPermissionEnforcer
  extend ActiveSupport::Concern

  included do
    helper_method :current_admin_permissions, :owner_admin_for_current_temple?
  end

  def require_capability!(capability)
    return if current_admin_permissions&.allow?(capability)

    redirect_to admin_dashboard_path, alert: "You do not have access to #{capability.to_s.humanize(capitalize: false)}."
  end

  def current_admin_permissions
    return nil unless current_admin&.admin_account

    @current_admin_permissions ||= current_admin.admin_account.permissions_for(current_temple)
  end

  # Billing (Stripe platform usage owed to SourceGrid, and ECPay setup) is
  # deliberately owner-only -- real money/provider-credential access, not a
  # delegable capability. Real bug, 2026-08-20: this used to check the
  # manage_permissions *capability* instead of actual temple-owner
  # membership, despite every caller's own naming/flash text ("owner_only",
  # "Only the temple owner can view platform billing") already stating the
  # intended rule correctly -- any admin granted manage_permissions could
  # reach real billing surfaces, not just other-admin management. Confirmed
  # via full grep that every caller of this method is billing-specific
  # (Admin::PlatformBillingController, Admin::PaymentMethodsController, the
  # nav owner_only gate, and the profile-dropdown billing links) -- none of
  # them actually meant "can manage other admins," so renamed to match what
  # it's actually gating instead of leaving the misleading name in place.
  def owner_admin_for_current_temple?
    current_admin&.admin_account&.owner_for_temple?(current_temple) || false
  end
end
