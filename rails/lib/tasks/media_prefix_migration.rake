# frozen_string_literal: true

# Phase 0 of ops/docs/plans/MEDIA_ASSET_REMOVAL_AND_ORPHAN_RECLAMATION_PLAN.md
#
# Moves production's media under a `prod/` prefix so every environment owns a
# namespace. Without it production's namespace is the bucket root, and a
# reclamation sweep there would treat dev/ and staging/ objects as orphans.
#
# DRY RUN IS THE DEFAULT. `apply=1` is required to write anything, and even
# then this never deletes: the originals stay until step 6 is done by hand.
namespace :media do
  desc "Report (or with apply=1, perform) the production S3 prefix migration"
  task :migrate_prefix, [:target_prefix] => :environment do |_t, args|
    target = (args[:target_prefix].presence || "prod").delete_suffix("/")
    apply = ENV["apply"].to_s == "1"

    current_prefix = ENV["S3_OBJECT_PREFIX"].to_s
    if current_prefix.present?
      abort "S3_OBJECT_PREFIX is already #{current_prefix.inspect}; this task is only for the unprefixed production namespace."
    end

    client = Storage::S3Service.send(:client)
    bucket = Storage::S3Service.send(:bucket)
    siblings = %w[dev staging].map { |p| "#{p}/" } + ["#{target}/"]

    puts "mode:   #{apply ? 'APPLY (writes)' : 'DRY RUN (writes nothing)'}"
    puts "bucket: #{bucket}"
    puts "target: #{target}/"
    puts ""

    # 1. objects to copy -- everything not already inside a namespace
    objects = []
    token = nil
    loop do
      resp = client.list_objects_v2(bucket: bucket, continuation_token: token)
      objects.concat(resp.contents.reject { |o| siblings.any? { |s| o.key.start_with?(s) } })
      token = resp.next_continuation_token
      break unless token
    end

    puts "objects to copy: #{objects.size} (#{(objects.sum(&:size) / 1048576.0).round(2)} MB)"
    objects.first(20).each { |o| puts "  #{o.key}  ->  #{target}/#{o.key}" }
    puts "  ... and #{objects.size - 20} more" if objects.size > 20
    puts ""

    # 2. MediaAsset rows whose file_uid points at the old namespace.
    #
    # Skips rows whose file_uid is a URL rather than a storage key. The seeded
    # placehold.co assets carry a full URL there and were never uploaded to S3,
    # so prefixing them would produce "prod/https://placehold.co/..." -- caught
    # by the first dry run against production, which is what it is for.
    rows = MediaAsset.where.not(file_uid: nil).reject do |a|
      uid = a.file_uid.to_s
      uid.start_with?("http://", "https://") || siblings.any? { |s| uid.start_with?(s) }
    end
    skipped = MediaAsset.where.not(file_uid: nil).count { |a| a.file_uid.to_s.start_with?("http://", "https://") }
    puts "media_asset file_uids to rewrite: #{rows.size}"
    puts "  (skipping #{skipped} rows whose file_uid is a URL, not a storage key -- seeded placeholders)" if skipped.positive?
    rows.first(20).each { |a| puts "  ##{a.id}  #{a.file_uid}  ->  #{target}/#{a.file_uid}" }
    puts ""

    # 3. stored URLs that embed the old path
    url_edits = []
    Temple.find_each do |temple|
      temple.hero_images.to_h.each do |tab, url|
        next if url.blank? || url.include?("/#{target}/") || url.include?("placehold.co")

        url_edits << ["Temple##{temple.id} hero_images[#{tab}]", url]
      end
    end
    { TempleEvent => %i[hero_image_url poster_image_url],
      TempleService => %i[hero_image_url],
      TempleGathering => %i[hero_image_url] }.each do |model, columns|
      columns.each do |column|
        next unless model.column_names.include?(column.to_s)

        model.where.not(column => [nil, ""]).find_each do |record|
          value = record.public_send(column)
          next if value.include?("/#{target}/") || value.include?("placehold.co")

          url_edits << ["#{model.name}##{record.id}.#{column}", value]
        end
      end
    end
    puts "stored URLs to rewrite: #{url_edits.size}"
    url_edits.first(20).each { |label, url| puts "  #{label}\n    #{url}" }
    puts ""

    unless apply
      puts "DRY RUN -- nothing was changed. Re-run with apply=1 to perform steps 2-4."
      puts "Do NOT set S3_OBJECT_PREFIX=#{target} until this has been applied and verified."
      next
    end

    puts "applying..."
    objects.each do |object|
      client.copy_object(bucket: bucket, copy_source: "#{bucket}/#{object.key}", key: "#{target}/#{object.key}")
    end
    puts "  copied #{objects.size} objects (originals left in place)"

    rows.each { |a| a.update!(file_uid: "#{target}/#{a.file_uid}") }
    puts "  rewrote #{rows.size} file_uids"

    rewritten = 0
    Temple.find_each do |temple|
      images = temple.hero_images.to_h
      changed = images.transform_values do |url|
        next url if url.blank? || url.include?("/#{target}/") || url.include?("placehold.co")

        rewritten += 1
        url.sub(%r{/uploads/}, "/#{target}/uploads/")
      end
      temple.update!(hero_images: changed) if changed != images
    end
    puts "  rewrote #{rewritten} temple hero URLs"
    puts ""
    puts "Next: verify the site renders, THEN set S3_OBJECT_PREFIX=#{target} and restart, THEN delete the originals."
  end
end
