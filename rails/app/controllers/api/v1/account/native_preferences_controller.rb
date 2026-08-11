# frozen_string_literal: true

module Api
  module V1
    module Account
      class NativePreferencesController < NativeBaseController
        def show
          render json: { preferences: payload(preference) }
        end

        def update
          updates = preference_params.to_h.symbolize_keys
          errors = []
          if updates.key?(:locale)
            locale = updates[:locale].to_s
            I18n.available_locales.map(&:to_s).include?(locale) ? preference.locale = locale : errors << "locale"
          end
          if updates.key?(:account_display_mode)
            mode = updates[:account_display_mode].to_s
            Themes::Policy.mode_ids(:account).include?(mode) ? preference.set_display_mode(:account, mode) : errors << "account_display_mode"
          end
          if updates.key?(:mobile_theme_id)
            theme = updates[:mobile_theme_id].to_s
            Themes::Policy.valid_mobile_theme_id?(theme) ? preference.set_mobile_theme_id(theme) : errors << "mobile_theme_id"
          end
          return render_error("invalid_preferences", :unprocessable_entity, details: errors) if errors.any?
          if preference.changed?
            changed_fields = preference.changes.keys
            preference.save!
            SystemAuditLogger.log!(
              action: "preferences.theme_updated",
              admin: current_native_user,
              target: preference,
              temple: current_native_temple,
              metadata: {
                actor_type: "user",
                source: "native_account_api",
                updated_fields: changed_fields
              }
            )
          end
          render json: { preferences: payload(preference) }
        end

        private

        def preference
          @native_preference ||= UserPreference.for_user(current_native_user)
        end
        def preference_params = params.fetch(:preferences, {}).permit(:locale, :account_display_mode, :mobile_theme_id)
        def payload(record) = { locale: record.locale, account_display_mode: record.display_mode_for(:account), mobile_theme_id: record.mobile_theme_id }.compact
      end
    end
  end
end
