# frozen_string_literal: true

module Api
  module V1
    module Account
      class NativeDependentsController < NativeBaseController
        before_action :set_link, only: %i[show update destroy]

        def index
          render json: { dependents: links.map { |link| ::Account::Api::NativeAccountSerializer.dependent(link) } }
        end

        def show
          render json: { dependent: ::Account::Api::NativeAccountSerializer.dependent(@link) }
        end

        def create
          save_form(::Account::DependentForm.new(user: current_native_user, params: dependent_params), "account.dependents.created")
        end

        def update
          save_form(::Account::DependentForm.new(user: current_native_user, link: @link, params: dependent_params), "account.dependents.updated")
        end

        def destroy
          dependent = @link.dependent
          @link.destroy!
          audit!("account.dependents.deleted", dependent, [])
          head :no_content
        end

        private

        def links
          current_native_user.user_dependents.includes(:dependent).order(:id)
        end

        def set_link
          @link = links.find(params[:id])
        end

        def dependent_params
          params.fetch(:dependent, {}).permit(:english_name, :native_name, :relationship_label, :birthdate, :phone, :email, :notes)
        end

        def save_form(form, action)
          return render_validation_errors(form) unless form.save
          audit!(action, form.link.dependent, dependent_params.keys)
          render json: { dependent: ::Account::Api::NativeAccountSerializer.dependent(form.link) }, status: action.end_with?("created") ? :created : :ok
        end

        def audit!(action, target, changed_fields)
          SystemAuditLogger.log!(action:, admin: current_native_user, target:, temple: current_native_temple, metadata: { actor_type: "user", source: "native_account_api", changed_fields: changed_fields.map(&:to_s) })
        end
      end
    end
  end
end
