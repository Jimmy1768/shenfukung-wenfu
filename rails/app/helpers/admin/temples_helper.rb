# frozen_string_literal: true

module Admin
  module TemplesHelper
    PLACEHOLDER_ASSET = "/backend/assets/admin/hero-placeholder.svg"

    def hero_image_preview_for(form, tab)
      tab_key = tab.to_s
      preview = form.hero_images[tab_key].presence || form.temple.hero_image_for(tab_key)
      preview.presence || PLACEHOLDER_ASSET
    end

    # The rule itself lives on Temple, so the view's show/hide and the
    # remover's audit-or-not cannot drift. The form's own hero_images is
    # consulted first so an unsaved paste-URL edit still shows the control.
    def hero_image_set_for?(form, tab)
      tab_key = tab.to_s
      form.hero_images[tab_key].present? || form.temple.hero_image_set?(tab_key)
    end
  end
end
