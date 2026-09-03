# frozen_string_literal: true

# Phase 0 of ops/docs/plans/MEDIA_ASSET_REMOVAL_AND_ORPHAN_RECLAMATION_PLAN.md
#
# Moves production's media under a `prod/` prefix so every environment owns a
# namespace. Without it production's namespace is the bucket root, and a
# reclamation sweep there would treat dev/ and staging/ objects as orphans.
#
# This is not an ActiveRecord migration: no schema change, no up/down. It is a
# one-off rake task, and `apply=1` is an env var on the command line, not code.
#
# DRY RUN IS THE DEFAULT. `apply=1` is required to write anything, and even
# then this never deletes: objects are copied, so the originals stay until
# step 6 is done by hand.
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
    region = Storage::S3Service.send(:region)
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

    # 3. stored URLs that embed the old path.
    #
    # A stored URL is "#{base}/#{storage_key}" (Storage::S3Service.public_url),
    # so splitting at the base and namespacing the key is exact for every key
    # root. Substituting on "/uploads/" was not: ManagedUploader writes
    # gallery/images/, gallery/videos/ and gatherings/hero/, which would have
    # been reported and then silently left alone.
    #
    # Matching the base is also what makes the predicate right -- a hand-pasted
    # external URL is not ours, so it is neither reported nor touched.
    bases = [
      ENV["S3_PUBLIC_BASE_URL"].presence,
      "https://#{bucket}.s3.#{region}.amazonaws.com"
    ].compact.map { |b| b.to_s.chomp("/") }

    split = lambda do |url|
      base = bases.find { |b| url.to_s.start_with?("#{b}/") }
      base ? [base, url.to_s.delete_prefix("#{base}/")] : nil
    end
    stale = ->(url) { (parts = split.call(url)) && !parts[1].start_with?("#{target}/") }
    rewrite = lambda do |url|
      base, key = split.call(url)
      "#{base}/#{target}/#{key}"
    end

    # Each edit carries its own applier, so the list that gets printed is
    # exactly the list that gets written. They cannot drift apart.
    url_edits = []
    Temple.find_each do |temple|
      temple.hero_images.to_h.each do |tab, url|
        next unless stale.call(url)

        url_edits << ["Temple##{temple.id} hero_images[#{tab}]", url, lambda {
          temple.update!(hero_images: temple.hero_images.to_h.merge(tab => rewrite.call(url)))
        }]
      end
    end
    { TempleEvent => %i[hero_image_url poster_image_url],
      TempleService => %i[hero_image_url],
      TempleGathering => %i[hero_image_url] }.each do |model, columns|
      columns.each do |column|
        next unless model.column_names.include?(column.to_s)

        model.where.not(column => [nil, ""]).find_each do |record|
          value = record.public_send(column)
          next unless stale.call(value)

          url_edits << ["#{model.name}##{record.id}.#{column}", value, lambda {
            record.update!(column => rewrite.call(value))
          }]
        end
      end
    end
    puts "stored URLs to rewrite: #{url_edits.size}"
    url_edits.first(20).each { |label, url, _applier| puts "  #{label}\n    #{url}" }
    puts "  ... and #{url_edits.size - 20} more" if url_edits.size > 20
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

    url_edits.each { |_label, _url, applier| applier.call }
    puts "  rewrote #{url_edits.size} stored URLs"
    puts ""
    puts "Next: verify the site renders, THEN set S3_OBJECT_PREFIX=#{target} and restart, THEN delete the originals."
  end
end
