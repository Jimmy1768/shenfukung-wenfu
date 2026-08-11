# frozen_string_literal: true

module Api
  module V1
    module Account
      class NativeProfileController < NativeBaseController
        def show
          render json: { user: ::Account::Api::NativeAccountSerializer.user(current_native_user) }
        end

        def update
          form = ::Account::ProfileForm.new(user: current_native_user, params: profile_params)
          return render_validation_errors(form) unless form.save

          audit!("account.profile.updated", current_native_user, profile_params.keys)
          render json: { user: ::Account::Api::NativeAccountSerializer.user(current_native_user) }
        end

        def password
          form = ::Account::PasswordSettingsForm.new(user: current_native_user, params: password_params)
          return render_validation_errors(form) unless form.save

          audit!("account.password.added", current_native_user, [])
          head :no_content
        end

        private

        def profile_params
          params.fetch(:profile, {}).permit(:english_name, :native_name, :phone, :city, :notes)
        end

        def password_params
          params.fetch(:password, {}).permit(:password, :password_confirmation)
        end

        def audit!(action, target, changed_fields)
          SystemAuditLogger.log!(action:, admin: current_native_user, target:, temple: current_native_temple, metadata: { actor_type: "user", source: "native_account_api", changed_fields: changed_fields.map(&:to_s) })
        end
      end
    end
  end
end
