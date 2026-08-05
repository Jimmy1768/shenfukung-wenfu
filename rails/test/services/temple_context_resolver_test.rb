# frozen_string_literal: true

require "test_helper"

class TempleContextResolverTest < ActiveSupport::TestCase
  test "admin resolver ignores generic temple form params and uses assigned session context" do
    temple = create_temple(slug: "admin-temple")
    admin = create_admin_user(temple: temple, role: "owner").admin_account

    result = TempleContextResolver.new(
      params: ActionController::Parameters.new(temple: { name: "Updated Temple" }),
      session: { TempleContextResolver::ADMIN_TEMPLE_SESSION_KEY => temple.slug },
      surface: :admin,
      admin_account: admin
    ).resolve

    assert_equal temple, result.temple
    assert_equal temple.slug, result.slug
    assert_equal :session_admin_temple_slug, result.source
  end

  test "account resolver accepts canonical temple slug before legacy temple slug" do
    canonical = create_temple(slug: "canonical-temple")
    create_temple(slug: "legacy-temple")

    result = TempleContextResolver.new(
      params: ActionController::Parameters.new(
        temple_slug: canonical.slug,
        temple: "legacy-temple"
      ),
      session: {},
      surface: :account
    ).resolve

    assert_equal canonical, result.temple
    assert_equal :request_temple_slug, result.source
  end

  test "public resolver uses only the configured project slug" do
    project_temple = create_temple(slug: AppConstants::Project.slug)
    requested_temple = create_temple(slug: "requested-temple")

    result = TempleContextResolver.new(
      params: ActionController::Parameters.new(
        temple_slug: requested_temple.slug,
        tenant_slug: requested_temple.slug,
        slug: requested_temple.slug,
        temple: requested_temple.slug
      ),
      session: {},
      surface: :public
    ).resolve

    assert_equal project_temple, result.temple
    assert_equal project_temple.slug, result.slug
    assert_equal :project_default, result.source
  end
end
