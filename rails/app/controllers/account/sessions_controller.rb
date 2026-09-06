module Account
  class SessionsController < BaseController
    skip_before_action :authenticate_user!, only: %i[new create destroy]
    skip_before_action :ensure_temple_context, only: %i[new create destroy]
    skip_before_action :verify_authenticity_token, only: %i[create destroy]
    before_action :capture_entry_intent_from_params!, only: :new
    before_action :redirect_authenticated_user_with_intent!, only: :new

    def new
      @registration_form = Account::RegistrationForm.new
      @show_registration_modal = params[:register] == "email"
    end

    def create
      if valid_credentials?
        user = User.find_by(email: session_params[:email].to_s.downcase.strip)
        if user.closed_account?
          flash.now[:alert] = I18n.t("account.sessions.flash.account_closed")
          @registration_form ||= Account::RegistrationForm.new
          return render :new, status: :unprocessable_content
        end

        establish_user_session!(user)
        redirect_to resolve_post_login_path, notice: I18n.t("account.sessions.flash.signed_in")
      else
        flash.now[:alert] = I18n.t("account.sessions.flash.invalid_credentials")
        @registration_form ||= Account::RegistrationForm.new
        render :new, status: :unprocessable_content
      end
    end

    def destroy
      destroy_user_session!
      redirect_to account_login_path, notice: I18n.t("account.sessions.flash.signed_out")
    end

    private

    def valid_credentials?
      creds = session_params
      email = creds[:email].to_s.downcase.strip
      password = creds[:password].to_s
      return false if email.blank? || password.blank?

      user = User.find_by(email: email)
      return false unless user

      user.valid_password_and_upgrade!(password)
    end

    def session_params
      params.fetch(:session, ActionController::Parameters.new).permit(:email, :password)
    end

    def redirect_authenticated_user_with_intent!
      return unless user_signed_in?
      return if account_entry_intent.blank?

      redirect_to resolve_post_login_path
    end
  end
end
