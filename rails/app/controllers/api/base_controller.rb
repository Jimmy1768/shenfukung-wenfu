# Api::BaseController
# Base controller for all JSON API endpoints.
# Used by versioned API namespaces (e.g. Api::V1::SomeController).
#
# Deliberately provides no authentication. Most direct subclasses are public,
# unauthenticated tenant endpoints (temples, events, gatherings, services,
# news, galleries, contact requests), so a base-level authenticate filter
# would be wrong here rather than merely missing.
#
# Authenticated surfaces add their own boundary in the subclass. The native
# account API does this in Api::V1::Account::NativeBaseController: bearer JWT,
# an "account"-scoped token check, and refresh-session revocation, kept
# separate from Account::BaseController's browser-cookie/admin-aware helpers.
module Api
  class BaseController < ActionController::API
    include TempleContext
  end
end
