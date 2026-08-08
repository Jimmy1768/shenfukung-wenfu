require "test_helper"

class AdminLayoutCssTest < ActiveSupport::TestCase
  test "setup draft form uses droplet-style fluid two-column offering stage" do
    layout_css = Rails.root.join("app/stylesheets/admin/_layout.scss").read
    components_css = Rails.root.join("app/stylesheets/admin/_components.scss").read
    setup_form = Rails.root.join("app/views/admin/offering_setup_drafts/_form.html.erb").read
    gathering_form = Rails.root.join("app/views/admin/gatherings/_form.html.erb").read
    gathering_new = Rails.root.join("app/views/admin/gatherings/new.html.erb").read
    compiled_css = Rails.root.join("public/backend/assets/admin.css").read

    assert_match(/@supports \(width: fit-content\(560px\)\)/, layout_css)
    assert_includes setup_form, 'class: "form-stack stack-item stack-item--fluid"'
    assert_includes setup_form, 'class="offering-form-stage offering-setup-form-stage"'
    assert_includes setup_form, 'class="offering-form-stage__primary"'
    assert_includes setup_form, 'class="offering-form-stage__secondary-list"'
    assert_match(/@media \(min-width: 900px\)\s*\{[^}]*\.offering-form-stage\s*\{[^}]*grid-template-columns:\s*minmax\(360px, 1\.15fr\) minmax\(280px, 0\.9fr\);/m, components_css)
    assert_match(/@media \(min-width: 900px\)\s*\{[^}]*\.offering-form-stage\s*\{[^}]*grid-template-columns:\s*minmax\(360px, 1\.15fr\) minmax\(280px, 0\.9fr\);/m, compiled_css)

    assert_includes gathering_form, 'class: "form-stack stack-item stack-item--fluid gathering-form"'
    assert_includes gathering_form, 'class="offering-form-stage gathering-form-stage"'
    assert_includes gathering_form, 'class="offering-form-stage__primary"'
    assert_includes gathering_form, 'class="offering-form-stage__secondary-list"'
    assert_match(/<section class="card stack-item stack-item--wide">[\s\S]*<\/section>\s*<\/div>\s*\n\s*<div class="admin-stack__row">\s*<%= render "form", gathering: @gathering %>/, gathering_new)
    assert_includes components_css, ".gathering-form-stage"
    assert_includes compiled_css, ".gathering-form-stage"
  end

  test "admin flash badges wrap instead of forcing horizontal overflow" do
    layout_css = Rails.root.join("app/stylesheets/admin/_layout.scss").read
    compiled_css = Rails.root.join("public/backend/assets/admin.css").read

    assert_match(/\.admin-flash-tray\s*\{[^}]*min-width:\s*0;/m, layout_css)
    assert_match(/\.admin-flash\s*\{[^}]*white-space:\s*normal;/m, layout_css)
    assert_match(/\.admin-flash\s*\{[^}]*overflow-wrap:\s*anywhere;/m, layout_css)
    assert_match(/\.admin-flash-tray\s*\{[^}]*min-width:\s*0;/m, compiled_css)
    assert_match(/\.admin-flash\s*\{[^}]*white-space:\s*normal;/m, compiled_css)
    assert_match(/\.admin-flash\s*\{[^}]*overflow-wrap:\s*anywhere;/m, compiled_css)
  end

  test "permission cards and controls have responsive, keyboard-visible styling in source and compiled CSS" do
    components_css = Rails.root.join("app/stylesheets/admin/_components.scss").read
    layout_css = Rails.root.join("app/stylesheets/admin/_layout.scss").read
    compiled_css = Rails.root.join("public/backend/assets/admin.css").read
    permission_view = Rails.root.join("app/views/admin/permissions/index.html.erb").read

    assert_includes permission_view, 'class="permission-grid"'
    assert_includes permission_view, 'class="permission-card"'
    assert_includes permission_view, 'class="checkbox permission-checkbox"'
    assert_includes permission_view, 'class="permission-actions"'
    assert_match(/\.permission-grid\s*\{[^}]*gap:/m, components_css)
    assert_match(/\.permission-card\s*\{[^}]*border:.*border-radius:.*padding:/m, components_css)
    assert_match(/\.permission-checkbox\s*\{[^}]*grid-template-columns:.*min-height:/m, components_css)
    assert_includes components_css, ".permission-checkbox:has(input:checked)"
    assert_includes components_css, ".permission-checkbox:has(input:focus-visible)"
    assert_match(/\.permission-actions\s*\{[^}]*border-top:.*padding:/m, components_css)
    assert_includes layout_css, ".sidebar-link-state"
    assert_includes compiled_css, ".permission-checkbox:has(input:focus-visible)"
    assert_includes compiled_css, ".sidebar-link-state"
  end

  test "permission copy is localized for both supported admin locales" do
    %i[en zh-TW].each do |locale|
      assert I18n.exists?("admin.permissions.index.body", locale)
      assert I18n.exists?("admin.permissions.index.empty", locale)
      assert I18n.exists?("admin.permissions.capabilities.manage_offerings.hint", locale)
      assert I18n.exists?("admin.permissions.capabilities.record_cash_payments.hint", locale)
      assert I18n.exists?("admin.permissions.capabilities.view_guest_lists.hint", locale)
      assert I18n.exists?("admin.nav.read_only", locale)
    end
  end
end
