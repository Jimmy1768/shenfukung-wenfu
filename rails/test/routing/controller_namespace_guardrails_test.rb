# frozen_string_literal: true

require "test_helper"

class ControllerNamespaceGuardrailsTest < ActionDispatch::IntegrationTest
  test "tenant-local public and account programmatic endpoints route under api v1" do
    assert_equal(
      { format: :json, controller: "api/v1/temples", action: "show" },
      Rails.application.routes.recognize_path("/api/v1/temple", method: :get)
    )

    assert_equal(
      { format: :json, controller: "api/v1/temple_news", action: "index" },
      Rails.application.routes.recognize_path("/api/v1/temple/news", method: :get)
    )

    assert_equal(
      { format: :json, controller: "api/v1/temple_events", action: "show", event_slug: "summer-festival" },
      Rails.application.routes.recognize_path("/api/v1/temple/events/summer-festival", method: :get)
    )

    assert_equal(
      { format: :json, controller: "api/v1/temple_services", action: "show", service_slug: "prayer-service" },
      Rails.application.routes.recognize_path("/api/v1/temple/services/prayer-service", method: :get)
    )

    assert_equal(
      { format: :json, controller: "api/v1/contact_temple_requests", action: "create" },
      Rails.application.routes.recognize_path("/api/v1/temple/contact_temple_requests", method: :post)
    )

    assert_equal(
      { format: :json, controller: "api/v1/account/registrations", action: "index" },
      Rails.application.routes.recognize_path("/api/v1/account/registrations", method: :get)
    )

    assert_equal(
      { format: :json, controller: "api/v1/account/payment_statuses", action: "show", reference: "ABC123" },
      Rails.application.routes.recognize_path("/api/v1/account/payment_statuses/ABC123", method: :get)
    )
  end

  test "plural public temple routes are not routable" do
    [
      ["/api/v1/temples/another-temple", :get],
      ["/api/v1/temples/another-temple/news", :get],
      ["/api/v1/temples/another-temple/archive", :get],
      ["/api/v1/temples/another-temple/events", :get],
      ["/api/v1/temples/another-temple/events/festival", :get],
      ["/api/v1/temples/another-temple/services", :get],
      ["/api/v1/temples/another-temple/services/prayer", :get],
      ["/api/v1/temples/another-temple/gatherings", :get],
      ["/api/v1/temples/another-temple/contact_temple_requests", :post]
    ].each do |path, method|
      assert_raises(ActionController::RoutingError, path) do
        Rails.application.routes.recognize_path(path, method:)
      end
    end
  end

  test "legacy account api routes are not routable" do
    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path("/account/api/registrations", method: :get)
    end

    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path("/account/api/payment_statuses/ABC123", method: :get)
    end
  end

  test "marketing admin showcase routes to demo controllers" do
    assert_equal(
      { controller: "demo/sessions", action: "new" },
      Rails.application.routes.recognize_path("/marketing/admin", method: :get)
    )

    assert_equal(
      { controller: "demo/dashboard", action: "index" },
      Rails.application.routes.recognize_path("/marketing/admin/dashboard", method: :get)
    )
  end

  test "html namespaces remain unversioned" do
    assert_equal(
      { format: :html, controller: "account/dashboard", action: "index" },
      Rails.application.routes.recognize_path("/account/dashboard", method: :get)
    )

    assert_equal(
      { format: :html, controller: "admin/dashboard", action: "index" },
      Rails.application.routes.recognize_path("/admin/dashboard", method: :get)
    )

    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path("/account/v1/dashboard", method: :get)
    end

    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path("/admin/v1/dashboard", method: :get)
    end
  end
end
