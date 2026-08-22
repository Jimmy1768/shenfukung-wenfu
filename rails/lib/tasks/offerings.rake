# frozen_string_literal: true

namespace :offerings do
  desc "Create (if missing) and sync every offering template in db/temples/offerings/<slug>.yml as a real, published offering"
  task :apply_templates, [:slug] => :environment do |_task, args|
    slug = args[:slug] || AppConstants::Project.slug
    temple = Temple.find_by!(slug:)
    loader = Offerings::TemplateLoader.new(temple.slug)

    created = []
    already_present = []

    loader.services.each do |template|
      existing = temple.temple_services.find_by(slug: template[:slug])
      if existing
        already_present << template[:slug]
        next
      end

      temple.temple_services.create!(
        slug: template[:slug],
        title: template[:label],
        status: "published",
        registration_period_key: template[:registration_period_key],
        price_cents: template.dig(:attributes, :price_cents),
        currency: template.dig(:attributes, :currency)
      )
      created << template[:slug]
    end

    loader.events.each do |template|
      existing = temple.temple_events.find_by(slug: template[:slug])
      if existing
        already_present << template[:slug]
        next
      end

      temple.temple_events.create!(
        slug: template[:slug],
        title: template[:label],
        status: "published",
        price_cents: template.dig(:attributes, :price_cents),
        currency: template.dig(:attributes, :currency)
      )
      created << template[:slug]
    end

    # TemplateSync only updates offerings that already exist by slug -- run
    # it after creation so every template (newly created just now, or
    # already present from a prior run) ends up with the full metadata
    # (registration_form, form_fields, options, etc.) the YAML declares,
    # not just the bare attributes set above.
    result = Offerings::TemplateSync.call(temple)

    SystemAuditLogger.log!(
      action: "offerings.templates_applied",
      temple:,
      metadata: {
        created:,
        already_present:,
        synced_services: result.updated_services,
        synced_events: result.updated_events
      }
    )

    puts "#{slug}: created #{created.size} offering(s) #{created.inspect}, #{already_present.size} already present #{already_present.inspect}." # rubocop:disable Rails/Output
    puts "#{slug}: synced metadata for services #{result.updated_services.inspect}, events #{result.updated_events.inspect}." # rubocop:disable Rails/Output
  end
end
