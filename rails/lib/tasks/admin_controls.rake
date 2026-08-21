# frozen_string_literal: true

module AdminControlsTasks
  module_function

  def default_admin_email(slug)
    "admin@#{slug}.local"
  end

  def seed_metadata(source)
    {
      provisioned_by: source,
      provisioned_at: Time.current.iso8601
    }
  end

  # Persistent, well-known account for one purpose: simulate what a real,
  # limited-permission admin sees, on production, without needing a real
  # staff member's account. Distinct from an owner's own account (owner of
  # every temple, for full access, not debugging) -- this one is never
  # granted the owner membership role, so it also correctly proves
  # owner-only gates (like Billing) stay blocked. One shared identity
  # across temples; re-running the seed task moves it to a different
  # temple with a fresh, all-false permission baseline rather than
  # accumulating stale grants. Specific capabilities for a given debug
  # session are toggled afterward through the real Permissions admin page
  # -- exercising that real UI path too, not a second parallel mechanism.
  def qa_dummy_admin_email
    "qa-dummy-admin@sourcegridlabs.com"
  end
end

namespace :admin_controls do
  desc "Dev helper: create/update an owner admin (User + AdminAccount + membership)"
  task :seed_owner, [:slug, :email, :password, :name] => :environment do |_task, args|
    slug = args[:slug] || AppConstants::Project.slug
    email = args[:email] || AdminControlsTasks.default_admin_email(slug)
    password = args[:password] || ENV.fetch("PROJECT_DEFAULT_ADMIN_PASSWORD", "GoldenTemplate!123")
    english_name = args[:name] || "#{slug.titleize} Owner Admin"

    temple = Temple.find_by!(slug:)
    user = User.find_or_initialize_by(email: email.downcase)
    user.english_name = english_name if user.english_name.blank?
    user.encrypted_password = User.password_hash(password)
    user.metadata = (user.metadata || {}).merge(AdminControlsTasks.seed_metadata("admin_controls:seed_owner"))
    user.save!

    admin = AdminAccount.find_or_initialize_by(user:)
    admin.role = :owner
    admin.active = true
    admin.metadata = (admin.metadata || {}).merge(AdminControlsTasks.seed_metadata("admin_controls:seed_owner"))
    admin.save!

    AdminTempleMembership.find_or_create_by!(admin_account: admin, temple:) do |membership|
      membership.role = :owner
    end

    puts "Owner admin ready for #{slug} (#{email})." # rubocop:disable Rails/Output
  end

  desc "Promote an existing user (by email) to owner admin for a temple"
  task :promote_owner, [:slug, :email] => :environment do |_task, args|
    slug = args[:slug] || AppConstants::Project.slug
    email = args[:email]
    raise ArgumentError, "email is required" if email.blank?

    temple = Temple.find_by!(slug:)
    user = User.find_by!(email: email.downcase)

    admin = AdminAccount.find_or_initialize_by(user:)
    admin.role = :owner
    admin.active = true
    admin.metadata = (admin.metadata || {}).merge(AdminControlsTasks.seed_metadata("admin_controls:promote_owner"))
    admin.save!

    AdminTempleMembership.find_or_create_by!(admin_account: admin, temple:) do |membership|
      membership.role = :owner
    end

    puts "User #{email} is now an owner admin for #{slug}." # rubocop:disable Rails/Output
  end

  desc "Assign the persistent QA dummy admin (never owner role) to a temple with a fresh, all-false permission baseline"
  task :seed_qa_dummy_admin, [:slug, :password] => :environment do |_task, args|
    slug = args[:slug] || AppConstants::Project.slug
    temple = Temple.find_by!(slug:)
    email = AdminControlsTasks.qa_dummy_admin_email

    user = User.find_by(email:)
    if user.nil?
      password = args[:password] || ENV.fetch("QA_DUMMY_ADMIN_PASSWORD") do
        raise ArgumentError, "First run needs a password: PASSWORD or QA_DUMMY_ADMIN_PASSWORD"
      end
      user = User.create!(
        email:,
        english_name: "QA Dummy Admin",
        encrypted_password: User.password_hash(password),
        metadata: AdminControlsTasks.seed_metadata("admin_controls:seed_qa_dummy_admin")
      )
    end

    admin = AdminAccount.find_or_initialize_by(user:)
    admin.role = :admin # never :owner -- this account exists to prove owner-only gates stay blocked, not to bypass them
    admin.active = true
    admin.metadata = (admin.metadata || {}).merge(AdminControlsTasks.seed_metadata("admin_controls:seed_qa_dummy_admin"))
    admin.save!

    membership = AdminTempleMembership.find_or_initialize_by(admin_account: admin, temple:)
    membership.role = :admin
    membership.save!

    permission = AdminPermission.find_or_initialize_by(admin_account: admin, temple:)
    AdminPermission::CAPABILITIES.each { |capability| permission[capability] = false }
    permission.save!

    puts "QA dummy admin (#{email}) assigned to #{slug} as a plain admin, permissions reset to all-false. Toggle specific capabilities via the real Permissions page as needed." # rubocop:disable Rails/Output
  end

  desc "Remove the QA dummy admin's membership/permissions from a temple (leaves the account intact for reassignment elsewhere)"
  task :remove_qa_dummy_admin, [:slug] => :environment do |_task, args|
    slug = args[:slug] || AppConstants::Project.slug
    temple = Temple.find_by!(slug:)
    user = User.find_by(email: AdminControlsTasks.qa_dummy_admin_email)
    unless user&.admin_account
      puts "QA dummy admin has no presence on #{slug}; nothing to remove." # rubocop:disable Rails/Output
      next
    end

    admin = user.admin_account
    AdminPermission.where(admin_account: admin, temple:).destroy_all
    AdminTempleMembership.where(admin_account: admin, temple:).destroy_all
    puts "QA dummy admin removed from #{slug}." # rubocop:disable Rails/Output
  end
end
