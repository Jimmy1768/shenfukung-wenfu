require "test_helper"

class AdminSessionsTest < ActionDispatch::IntegrationTest
  test "signs in with seeded admin credentials" do
    temple = create_temple(slug: "shengfukung-wenfu")
    admin = create_admin_user(temple:)

    post admin_sessions_path, params: { session: { email: admin.email, password: "Password123!" } }
    assert_redirected_to admin_dashboard_path
  end

  test "rejects invalid credentials" do
    temple = create_temple
    admin = create_admin_user(temple:)

    post admin_sessions_path, params: { session: { email: admin.email, password: "wrong" } }
    assert_response :unprocessable_entity
  end

  test "login page includes responsive viewport metadata" do
    get admin_login_path

    assert_response :success
    assert_includes response.body, '<meta name="viewport" content="width=device-width, initial-scale=1" />'
  end

  test "QA dummy admin authenticates against QA_DUMMY_ADMIN_PASSWORD directly, not its stored hash" do
    temple = create_temple(slug: "shengfukung-wenfu")
    email = AppConstants::Emails.qa_dummy_admin_email
    user = User.create!(email:, english_name: "QA Dummy Admin", encrypted_password: User.password_hash("whatever-was-hashed-at-creation"))
    admin = AdminAccount.create!(user:, active: true, role: "admin")
    AdminTempleMembership.create!(admin_account: admin, temple:, role: "admin")

    with_env("QA_DUMMY_ADMIN_PASSWORD" => "CurrentEnvPassword!") do
      post admin_sessions_path, params: { session: { email:, password: "CurrentEnvPassword!" } }
      assert_redirected_to admin_dashboard_path, "must authenticate against the current env value"

      post admin_sessions_path, params: { session: { email:, password: "whatever-was-hashed-at-creation" } }
      assert_response :unprocessable_entity, "the stored hash must not work once the env value has moved on"
    end

    with_env("QA_DUMMY_ADMIN_PASSWORD" => nil) do
      post admin_sessions_path, params: { session: { email:, password: "CurrentEnvPassword!" } }
      assert_response :unprocessable_entity, "removing the env var must make the account unusable even though the DB row still exists"
    end
  end

  test "an ordinary admin account is unaffected by the QA dummy admin's env-based check" do
    temple = create_temple
    admin = create_admin_user(temple:)

    with_env("QA_DUMMY_ADMIN_PASSWORD" => "SomeUnrelatedValue!") do
      post admin_sessions_path, params: { session: { email: admin.email, password: "Password123!" } }
      assert_redirected_to admin_dashboard_path

      post admin_sessions_path, params: { session: { email: admin.email, password: "SomeUnrelatedValue!" } }
      assert_response :unprocessable_entity, "the QA dummy admin's env var must never work as a password for a different account"
    end
  end

  private

  def with_env(overrides)
    previous = overrides.transform_keys(&:to_s).each_key.to_h { |key| [key, ENV[key]] }
    overrides.each { |key, value| ENV[key.to_s] = value }
    yield
  ensure
    previous.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end
end
