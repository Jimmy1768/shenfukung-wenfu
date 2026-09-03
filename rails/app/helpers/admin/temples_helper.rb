# frozen_string_literal: true

module Admin
  module TemplesHelper
    PLACEHOLDER_ASSET = "/backend/assets/admin/hero-placeholder.svg"

    # The admin shows ONLY this tab's own image. A tab that inherits 首頁 shows
    # the placeholder, because in the admin the question is "does this slot
    # have an image?" -- not "what will visitors see?". Rendering the inherited
    # picture here is a false positive: the slot is empty and looks filled.
    #
    # This used to happen by accident. The seed persisted a placehold.co URL in
    # every unset tab, the admin read the raw map and got that placeholder,
    # while the public site read hero_image_for, which sanitized placeholders
    # away and fell through to 首頁. Making absent mean absent removed the
    # accident, so the rule is stated directly instead.
    def hero_image_preview_for(form, tab)
      form.hero_images[tab.to_s].presence || PLACEHOLDER_ASSET
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
