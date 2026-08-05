# frozen_string_literal: true

require "test_helper"

class Api::V1::TenantLocalPublicApiTest < ActionDispatch::IntegrationTest
  test "singular public endpoints serve only the configured tenant" do
    configured_temple = create_temple(
      slug: AppConstants::Project.slug,
      name: "Configured Temple"
    )
    create_temple(slug: "other-temple", name: "Other Temple")

    get "/api/v1/temple", params: { slug: "other-temple", temple_slug: "other-temple", tenant_slug: "other-temple" }

    assert_response :success
    assert_equal configured_temple.slug, response.parsed_body.fetch("slug")
    assert_equal "Configured Temple", response.parsed_body.fetch("name")

    get "/api/v1/temple/news", params: { slug: "other-temple" }

    assert_response :success
    assert_equal [], response.parsed_body.fetch("news")
  end

  test "former plural public endpoint returns not found" do
    create_temple(slug: AppConstants::Project.slug)

    get "/api/v1/temples/other-temple"

    assert_response :not_found
  end
end
