# frozen_string_literal: true

module Admin
  class TemplesController < BaseController
    before_action :ensure_temple!
    before_action -> { require_capability!(:manage_profile) }
    skip_before_action :verify_authenticity_token, only: :update

    def edit
      @form = Admin::TempleProfileForm.new(temple: current_temple)
    end

    def update
      @form = Admin::TempleProfileForm.new(temple: current_temple, params: profile_params_with_uploads)

      if @form.save(current_admin:)
        redirect_to admin_temple_profile_path, notice: t("admin.temple_profile.flash.updated")
      else
        flash.now[:alert] = t("admin.temple_profile.flash.review_errors")
        render :edit, status: :unprocessable_entity
      end
    rescue MediaAssets::HeroImageUploader::UploadError, MediaAssets::HeroImageRemover::RemovalError => e
      @form = Admin::TempleProfileForm.new(temple: current_temple, params: temple_params)
      @form.errors.add(:hero_images, e.message)
      flash.now[:alert] = t("admin.temple_profile.flash.review_errors")
      render :edit, status: :unprocessable_entity
    end

    private

    def profile_params_with_uploads
      permitted = temple_params.to_h.deep_stringify_keys
      removed = remove_hero_images
      uploaded_urls = upload_hero_images

      # Removal runs BEFORE upload so replacing an image in the same save --
      # tick remove and choose a file -- ends with the new image rather than
      # nothing. It also has to strip the submitted hero_images value for that
      # tab, or the form would write the old URL straight back from the
      # still-populated "paste URL" box.
      permitted["hero_images"] = (permitted["hero_images"] || {}).except(*removed) if removed.any?
      permitted["hero_images"] = (permitted["hero_images"] || {}).merge(uploaded_urls) if uploaded_urls.present?
      permitted
    end

    # Clears both storage paths for a tab (the hero_images entry and the
    # MediaAsset binding) so it falls back to the home image. Unlink only --
    # see MediaAssets::HeroImageRemover.
    def remove_hero_images
      removal_params.filter_map do |tab, flag|
        next unless ActiveModel::Type::Boolean.new.cast(flag)

        MediaAssets::HeroImageRemover.call(
          temple: current_temple,
          hero_tab: tab,
          admin: current_admin
        )
        tab.to_s
      end
    end

    def removal_params
      raw = params.fetch(:hero_image_remove, {})
      raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h.slice(*Temple::HERO_TABS) : {}
    end

    def upload_hero_images
      upload_params.each_with_object({}) do |(tab, file), urls|
        next if file.blank?

        result = MediaAssets::HeroImageUploader.call(
          temple: current_temple,
          file: file,
          hero_tab: tab,
          admin: current_admin
        )
        urls[tab.to_s] = result[:url]
      end
    end

    def upload_params
      raw = params.fetch(:hero_image_upload, {})
      raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h.slice(*Temple::HERO_TABS) : {}
    end

    def temple_params
      params.require(:temple).permit(
        :name,
        :tagline,
        :hero_copy,
        :map_link,
        hero_images: Temple::HERO_TABS,
        contact: %i[phone],
        service_times: {},
        visit_info: %i[transportation parking],
        about: [
          :hero_subtitle,
          { cards: {
            history: [:body],
            deities: [:body],
            etiquette: [:body]
          } }
        ]
      )
    end

    def ensure_temple!
      return if current_temple.present?

      redirect_to admin_dashboard_path, alert: t("admin.temple_profile.flash.not_found")
    end
  end
end
