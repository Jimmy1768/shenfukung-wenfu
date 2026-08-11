# frozen_string_literal: true

module Api
  module V1
    module Account
      class NativeBootstrapController < NativeBaseController
        def show
          preference = UserPreference.for_user(current_native_user)
          render json: {
            user: ::Account::Api::NativeAccountSerializer.user(current_native_user),
            temple: ::Account::Api::NativeAccountSerializer.temple(current_native_temple),
            preferences: native_preferences(preference),
            registrations: current_native_user.temple_event_registrations.where(temple: current_native_temple).includes(:registrable).order(created_at: :desc).limit(3).map { |r| ::Account::Api::NativeAccountSerializer.registration(r) },
            certificates: current_native_user.temple_event_registrations.where(temple: current_native_temple).with_certificate_number.includes(:registrable).order(updated_at: :desc).limit(3).map { |r| ::Account::Api::CertificateSerializer.new(r).as_json }
          }
        end

        private

        def native_preferences(preference)
          { locale: preference.locale, account_display_mode: preference.display_mode_for(:account), mobile_theme_id: preference.mobile_theme_id }.compact
        end
      end
    end
  end
end
