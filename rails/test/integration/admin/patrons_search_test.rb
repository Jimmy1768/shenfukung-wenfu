require "test_helper"

class Admin::PatronsSearchTest < ActionDispatch::IntegrationTest
  setup do
    @temple = create_temple
    @owner = create_admin_user(temple: @temple, role: "owner")
  end

  test "searching the admins view does not 500 -- regression for the DISTINCT + ORDER BY bug" do
    sign_in_admin(@owner)

    get admin_patrons_path, params: { q: @owner.english_name, view: "admins" }

    assert_response :success
  end

  test "searching the admins view finds an admin by name" do
    staff = create_admin_user(temple: @temple, role: "admin")
    staff.update!(english_name: "Katelyn Staff")
    sign_in_admin(@owner)

    get admin_patrons_path, params: { q: "Katelyn", view: "admins" }

    assert_response :success
    assert_includes response.body, "Katelyn Staff"
  end

  test "searching the admins view excludes a patron who is not an admin of this temple" do
    patron = User.create!(email: "katelyn-patron@example.com", english_name: "Katelyn Patron",
      encrypted_password: User.password_hash("Password123!"))
    sign_in_admin(@owner)

    get admin_patrons_path, params: { q: "Katelyn", view: "admins" }

    assert_response :success
    refute_includes response.body, "Katelyn Patron"
  end

  test "searching the admins view does not 500 when the matched admin has a dependent -- regression for the ambiguous-column bug" do
    staff = create_admin_user(temple: @temple, role: "admin")
    staff.update!(english_name: "Katelyn Staff")
    dependent = Dependent.create!(english_name: "Unrelated Dependent Name")
    UserDependent.create!(user: staff, dependent:, role: "family", relationship_label: "Child")
    sign_in_admin(@owner)

    get admin_patrons_path, params: { q: "Katelyn", view: "admins" }

    assert_response :success
    assert_includes response.body, "Katelyn Staff"
  end

  test "searching the default (all/patron) view still works, unaffected" do
    User.create!(email: "katelyn-patron2@example.com", english_name: "Katelyn Everyone",
      encrypted_password: User.password_hash("Password123!"))
    sign_in_admin(@owner)

    get admin_patrons_path, params: { q: "Katelyn" }

    assert_response :success
    assert_includes response.body, "Katelyn Everyone"
  end
end
