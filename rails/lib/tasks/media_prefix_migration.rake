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

    client = Storage::S3Service.client
    bucket = Storage::S3Service.bucket
    siblings = %w[dev staging].map { |p| "#{p}/" } + ["#{target}/"]

    # Every section prints the same shape. It was pasted three times and had
    # already drifted -- the middle one silently dropped its "and N more", so a
    # bucket with 40 URL-valued rows would have shown 20 and no hint of the rest.
    report = lambda do |header, items, &line|
      puts header
      items.first(20).each { |item| puts "  #{line.call(item)}" }
      puts "  ... and #{items.size - 20} more" if items.size > 20
      puts ""
    end

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

    report.call("objects to copy: #{objects.size} (#{(objects.sum(&:size) / 1048576.0).round(2)} MB)", objects) do |o|
      "#{o.key}  ->  #{target}/#{o.key}"
    end

    # 2. MediaAsset rows whose file_uid points at the old namespace.
    #
    # Rows whose file_uid is a URL rather than a storage key are skipped: the
    # seeded placehold.co assets carry a full URL there and were never uploaded
    # to S3, so prefixing them would produce "prod/https://placehold.co/...".
    # Caught by the first dry run against production, which is what it is for.
    #
    # One load, split once -- the count used to re-query and re-instantiate the
    # whole table just to print the second number.
    url_valued, key_valued = MediaAsset.where.not(file_uid: nil).to_a.partition do |asset|
      asset.file_uid.to_s.start_with?("http://", "https://")
    end
    rows = key_valued.reject { |a| siblings.any? { |s| a.file_uid.to_s.start_with?(s) } }

    header = "media_asset file_uids to rewrite: #{rows.size}"
    header += "\n  (skipping #{url_valued.size} rows whose file_uid is a URL, not a storage key -- seeded placeholders)" if url_valued.any?
    report.call(header, rows) { |a| "##{a.id}  #{a.file_uid}  ->  #{target}/#{a.file_uid}" }

    # 3. stored URLs that embed the old path.
    #
    # A stored URL is "#{base}/#{storage_key}", so splitting at the base and
    # namespacing the key is exact for every key root. Substituting on
    # "/uploads/" was not: ManagedUploader writes gallery/images/,
    # gallery/videos/ and gatherings/hero/, which would have been reported and
    # then silently left alone.
    #
    # The base comes from Storage::S3Service rather than being rebuilt here.
    # Rebuilt, it stops matching the moment S3_PUBLIC_BASE_URL becomes a CDN
    # host -- and the failure is silent: "0 URLs to rewrite" on a full bucket.
    base = Storage::S3Service.public_url_base.chomp("/")

    # Returns the namespaced URL, or nil if this is not one of ours or is
    # already namespaced. One predicate instead of three lambdas that re-split
    # the same string, and it hands back the new value so the dry run can print
    # old -> new like the other two sections do.
    prefixed = lambda do |url|
      value = url.to_s
      next nil unless value.start_with?("#{base}/")

      key = value.delete_prefix("#{base}/")
      next nil if key.start_with?("#{target}/")

      "#{base}/#{target}/#{key}"
    end

    # Each edit carries what to write and where, so the list that gets printed
    # is exactly the list that gets written -- they cannot drift apart.
    url_edits = []
    Temple.find_each do |temple|
      temple.hero_images.to_h.each do |tab, url|
        new_url = prefixed.call(url)
        next unless new_url

        url_edits << { label: "Temple##{temple.id} hero_images[#{tab}]", old: url, new: new_url,
                       temple: temple, tab: tab }
      end
    end
    { TempleEvent => %i[hero_image_url poster_image_url],
      TempleService => %i[hero_image_url],
      TempleGathering => %i[hero_image_url] }.each do |model, columns|
      columns.each do |column|
        model.where.not(column => [nil, ""]).find_each do |record|
          value = record.public_send(column)
          new_url = prefixed.call(value)
          next unless new_url

          url_edits << { label: "#{model.name}##{record.id}.#{column}", old: value, new: new_url,
                         record: record, column: column }
        end
      end
    end

    report.call("stored URLs to rewrite: #{url_edits.size}", url_edits) do |e|
      "#{e[:label]}\n    #{e[:old]}\n    ->  #{e[:new]}"
    end

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

    # Grouped by temple: every tab used to issue its own full update! of the
    # same row, so one temple with eight stale tabs meant eight transactions
    # and eight writes to produce one row's worth of change.
    temple_edits, record_edits = url_edits.partition { |e| e[:temple] }
    temple_edits.group_by { |e| e[:temple] }.each do |temple, edits|
      merged = edits.each_with_object(temple.hero_images.to_h) { |e, h| h[e[:tab]] = e[:new] }
      temple.update!(hero_images: merged)
    end
    record_edits.each { |e| e[:record].update!(e[:column] => e[:new]) }
    puts "  rewrote #{url_edits.size} stored URLs"
    puts ""
    puts "Next: verify the site renders, THEN set S3_OBJECT_PREFIX=#{target} and restart, THEN delete the originals."
  end
end
