# frozen_string_literal: true

module Api
  module V1
    module Account
      class NativeRegistrationsController < NativeBaseController
        include ::Account::RegistrationIntent
        before_action :set_registration, only: %i[show edit update]

        def index
          render json: { registrations: registration_scope.includes(:registrable).order(created_at: :desc).map { |registration| ::Account::Api::NativeAccountSerializer.registration(registration) } }
        end

        def show
          render json: { registration: ::Account::Api::NativeAccountSerializer.registration(@registration) }
        end

        def new
          offering = find_offering_for_intent(params[:offering], params[:account_action])
          return render_error("offering_not_found", :not_found) unless offering
          return render_error("registration_intake_frozen", :forbidden) if current_native_temple.registration_intake_frozen?

          render json: { offering: { id: offering.id, slug: offering.slug, title: offering.title }, registration: intake_defaults(offering) }
        end

        def create
          return render_error("registration_intake_frozen", :forbidden) if current_native_temple.registration_intake_frozen?
          offering = find_offering_for_intent(params[:offering], params[:account_action])
          return render_error("offering_not_found", :not_found) unless offering

          form = ::Account::RegistrationIntakeForm.new(user: current_native_user, offering:, params: intake_params)
          return render_validation_errors(form) unless form.save
          audit!("account.registrations.created", form.registration, intake_params.keys)
          render json: { registration: ::Account::Api::NativeAccountSerializer.registration(form.registration) }, status: :created
        end

        def edit
          render json: { registration: ::Account::Api::NativeAccountSerializer.registration(@registration) }
        end

        def update
          return render_error("registration_not_editable", :forbidden) unless Registrations::LifecyclePolicy.new(@registration).gathering_editable?

          form = ::Account::RegistrationMetadataForm.new(registration: @registration, user: current_native_user, params: metadata_params)
          return render_validation_errors(form) unless form.save
          audit!("account.registrations.updated", @registration, metadata_params.keys)
          render json: { registration: ::Account::Api::NativeAccountSerializer.registration(@registration) }
        end

        private

        def current_user = current_native_user
        def current_temple = current_native_temple

        def registration_scope
          current_native_user.temple_event_registrations.where(temple: current_native_temple)
        end

        def set_registration
          @registration = registration_scope.find(params[:id])
        end

        def intake_params
          params.fetch(:registration, {}).permit(:quantity, :registrant_scope, :dependent_id, :contact_name, :contact_phone, :contact_email, :household_notes, :arrival_window, :ceremony_notes)
        end

        def metadata_params
          intake_params
        end

        def intake_defaults(offering)
          form = ::Account::RegistrationIntakeForm.new(user: current_native_user, offering: offering, params: {})
          { quantity: form.quantity, registrant_scope: form.registrant_scope, contact_name: form.contact_name, contact_phone: form.contact_phone, contact_email: form.contact_email, household_notes: form.household_notes }
        end

        def audit!(action, registration, fields)
          SystemAuditLogger.log!(action:, admin: current_native_user, target: registration, temple: current_native_temple, metadata: { actor_type: "user", source: "native_account_api", registration_reference: registration.reference_code, changed_fields: fields.map(&:to_s) })
        end
      end
    end
  end
end
