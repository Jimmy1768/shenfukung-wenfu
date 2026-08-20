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
          offering = offering_for_request
          return render_error("offering_not_found", :not_found) unless offering
          return render_error("registration_intake_frozen", :forbidden) if current_native_temple.registration_intake_frozen?

          render json: { offering: offering_payload(offering), registration: intake_defaults(offering), registrants: registrant_options }
        end

        def create
          return render_error("registration_intake_frozen", :forbidden) if current_native_temple.registration_intake_frozen?
          offering = offering_for_request
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
          # The form already merges reusable-offering defaults (arrival_window,
          # ceremony_notes) into its own attributes in its constructor -- the web
          # account flow gets them "for free" because it re-renders the same form
          # object. This JSON payload is a separate hand-rolled extraction and was
          # missing these two, so a returning patron's native app showed an empty
          # field the web account app would have prefilled from the exact same
          # cached value. Everything else in this hash was already correct.
          { quantity: form.quantity, registrant_scope: form.registrant_scope, contact_name: form.contact_name, contact_phone: form.contact_phone, contact_email: form.contact_email, household_notes: form.household_notes, arrival_window: form.arrival_window, ceremony_notes: form.ceremony_notes }
        end

        def offering_for_request
          action = params[:account_action].presence
          offering = find_offering_for_intent(params[:offering], action)
          return unless offering && action == account_action_for(offering)

          offering
        end

        def offering_payload(offering)
          {
            id: offering.id,
            slug: offering.slug,
            title: offering.title,
            account_action: account_action_for(offering),
            price_cents: offering.price_cents,
            currency: offering.currency
          }
        end

        def account_action_for(offering)
          case offering
          when TempleService then "service"
          when TempleGathering then "gathering"
          else "event"
          end
        end

        def registrant_options
          self_option = {
            scope: "self",
            id: current_native_user.id,
            label: current_native_user.native_name.presence || current_native_user.english_name.presence || current_native_user.email
          }
          dependents = current_native_user.dependents.order(:native_name, :english_name).map do |dependent|
            {
              scope: "dependent",
              id: dependent.id,
              label: dependent.native_name.presence || dependent.english_name
            }
          end
          [self_option, *dependents]
        end

        def audit!(action, registration, fields)
          SystemAuditLogger.log!(action:, admin: current_native_user, target: registration, temple: current_native_temple, metadata: { actor_type: "user", source: "native_account_api", registration_reference: registration.reference_code, changed_fields: fields.map(&:to_s) })
        end
      end
    end
  end
end
