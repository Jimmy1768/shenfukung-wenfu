# frozen_string_literal: true

module Admin
  module TemplesHelper
    PLACEHOLDER_ASSET = "/backend/assets/admin/hero-placeholder.svg"

    def hero_image_preview_for(form, tab)
      tab_key = tab.to_s
      preview = form.hero_images[tab_key].presence || form.temple.hero_image_for(tab_key)
      preview.presence || PLACEHOLDER_ASSET
    end

    # True when this tab has an image OF ITS OWN, as opposed to showing the
    # home image by inheritance. Only then is there anything to remove, so the
    # control stays hidden on tabs that are already inheriting.
    def hero_image_set_for?(form, tab)
      tab_key = tab.to_s
      return true if form.hero_images[tab_key].present?

      form.temple.hero_media_asset_for(tab_key).present?
    end
  end
end
