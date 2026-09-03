# frozen_string_literal: true

module MediaAssets
  # Clears a temple's hero image for one tab so it falls back to the 首頁
  # image, which is what the admin has always promised for unset tabs.
  #
  # temple.hero_images[tab] is the only thing the render path reads, so
  # clearing it is what removes the image. The MediaAsset is unlinked in the
  # same transaction to keep provenance honest: the row records an upload that
  # is no longer shown anywhere.
  #
  # Unlink, not delete: the MediaAsset row and its S3 object survive. The row
  # keeps the record of what was uploaded and when (Director's call), and the
  # now-unreferenced object is left for the orphan sweep described in
  # ops/docs/plans/MEDIA_ASSET_REMOVAL_AND_ORPHAN_RECLAMATION_PLAN.md.
  class HeroImageRemover
    class RemovalError < StandardError; end

    def self.call(...) = new(...).call

    def initialize(temple:, hero_tab:, admin: nil)
      @temple = temple
      @hero_tab = hero_tab.to_s
      @admin = admin
    end

    def call
      raise RemovalError, "Unsupported hero tab" unless Temple::HERO_TABS.include?(hero_tab)

      asset = temple.hero_media_asset_for(hero_tab)
      had_image = temple.hero_image_set?(hero_tab)

      Temple.transaction do
        clear_hero_map!
        unlink_asset!(asset)
      end

      log!(asset) if had_image
      { removed: had_image, asset: asset }
    end

    private

    attr_reader :temple, :hero_tab, :admin

    # Temple#hero_images already returns a fresh stringified hash, and
    # ActiveRecord skips the UPDATE when the value is unchanged, so neither a
    # dup nor a key? guard buys anything.
    def clear_hero_map!
      temple.update!(hero_images: temple.hero_images.except(hero_tab))
    end

    # Keeps the row and its file_uid/url; only the tab binding goes, so the
    # asset stops being found by Temple#hero_media_asset_for.
    def unlink_asset!(asset)
      return if asset.blank?

      metadata = (asset.metadata || {}).dup
      metadata.delete("hero_tab")
      metadata["unlinked_at"] = Time.current.iso8601
      metadata["unlinked_from_tab"] = hero_tab
      asset.update!(metadata: metadata)
    end

    def log!(asset)
      SystemAuditLogger.log!(
        action: "admin.temple_profile.hero_image_removed",
        admin: admin,
        target: temple,
        temple: temple,
        metadata: {
          hero_tab: hero_tab,
          media_asset_id: asset&.id,
          file_uid: asset&.file_uid,
          note: "unlinked only; the stored object is left for orphan reclamation"
        }
      )
    end
  end
end
