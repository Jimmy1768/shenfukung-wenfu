# frozen_string_literal: true

module Api
  module V1
    module Account
      class NativeSessionsController < NativeBaseController
        skip_before_action :authenticate_native_user!, only: %i[signup login refresh password_recovery password_reset]

        def signup
          form = ::Account::RegistrationForm.new(signup_params)
          return render_validation_errors(form) unless form.save

          render json: { user: ::Account::Api::NativeAccountSerializer.user(form.user), session: issue_session_payload(form.user, context: native_context) }, status: :created
        end

        def login
          user = User.find_by(email: login_params[:email].to_s.downcase.strip)
          unless valid_password?(user, login_params[:password]) && user.active_account?
            return render_error("invalid_credentials", :unauthorized)
          end

          render json: { user: ::Account::Api::NativeAccountSerializer.user(user), session: issue_session_payload(user, context: native_context) }
        end

        def refresh
          raw_token = params[:refresh_token].to_s
          record = ::RefreshToken.includes(:user).find_by(token_digest: Digest::SHA256.hexdigest(raw_token))
          return render_error("session_invalid", :unauthorized) unless record&.user&.active_account?

          result = Auth::RefreshToken.new(record.user).rotate!(raw_token)
          return render_error("session_#{result.error}", :unauthorized) unless result.success?

          render json: {
            session: {
              access_token: Auth::JwtService.encode({ "sub" => record.user.id, "native_session_id" => result.record.id, "scope" => "account" }),
              refresh_token: result.raw_token,
              token_type: "Bearer",
              expires_in: Auth::JwtConfig::ACCESS_TOKEN_TTL
            }
          }
        end

        def logout
          Auth::RefreshToken.new(current_native_user).revoke!(params[:refresh_token].to_s)
          current_native_session.update!(revoked: true) unless current_native_session.revoked?
          head :no_content
        end

        # This intentionally returns the same accepted response for unknown,
        # closed, and valid emails. Delivery stays in the existing mailer.
        def password_recovery
          if (user = User.find_by(email: params[:email].to_s.downcase.strip))&.active_account?
            raw_token = Auth::PasswordReset.request_reset_for(user)
            Auth::PasswordMailer.reset_email(user: user, reset_url: edit_password_url(token: raw_token)) if raw_token.present?
          end
          render json: { accepted: true }, status: :accepted
        rescue StandardError
          render json: { accepted: true }, status: :accepted
        end

        def password_reset
          return render_error("invalid_password", :unprocessable_entity) unless params[:password].to_s == params[:password_confirmation].to_s

          result = Auth::PasswordReset.reset_password(params[:token].to_s, params[:password].to_s)
          return render_error("invalid_or_expired_reset", :unprocessable_entity) unless result.success?

          Auth::RefreshToken.new(result.user).revoke_all!
          render json: { user: ::Account::Api::NativeAccountSerializer.user(result.user), session: issue_session_payload(result.user, context: native_context) }
        end

        private

        def signup_params
          params.fetch(:signup, {}).permit(:email, :password, :password_confirmation)
        end

        def login_params
          params.fetch(:session, {}).permit(:email, :password)
        end

        def valid_password?(user, password)
          return false if user.blank? || password.blank? || user.encrypted_password.blank?
          expected = User.password_hash(password)
          user.encrypted_password.bytesize == expected.bytesize && ActiveSupport::SecurityUtils.secure_compare(user.encrypted_password, expected)
        end
      end
    end
  end
end
