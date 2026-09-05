# frozen_string_literal: true

module Api
  module V1
    module Account
      class NativeResourcesController < NativeBaseController
        include ::Account::RegistrationIntent

        def events
          render json: {
            events: current_native_temple.temple_events.upcoming_or_active.order_for_patrons.map { |event| offering_payload(event) },
            gatherings: current_native_temple.temple_gatherings.where(status: "published").order_for_patrons.map { |gathering| offering_payload(gathering) }
          }
        end

        def services
          render json: { services: current_native_temple.temple_services.published_visible.order(:title).map { |service| offering_payload(service) } }
        end

        def galleries
          entries = current_native_temple.temple_gallery_entries.recent_first
          entries = entries.where(id: params[:id]) if params[:id].present?
          payload = entries.map { |entry| { id: entry.id, title: entry.title, body: entry.body, event_date: entry.event_date, photo_urls: entry.photo_urls } }
          return render_error("not_found", :not_found) if params[:id].present? && payload.empty?
          render json: params[:id].present? ? { gallery: payload.first } : { galleries: payload }
        end

        def certificates
          registrations = current_native_user.temple_event_registrations.where(temple: current_native_temple).with_certificate_number.includes(:registrable).order(updated_at: :desc)
          render json: { certificates: registrations.map { |registration| ::Account::Api::CertificateSerializer.new(registration).as_json } }
        end

        def assistance
          registration = registration_for_assistance
          existing = TempleAssistanceRequest.find_open_for(temple: current_native_temple, user: current_native_user, temple_registration: registration)
          return render json: { assistance_request: { id: existing.id, status: existing.status }, duplicate: true }, status: :ok if existing

          request_record = current_native_temple.temple_assistance_requests.create!(user: current_native_user, temple_registration: registration, status: "open", requested_at: Time.current, channel: assistance_params[:channel], message: assistance_params[:message].presence)
          audit!("account.assistance_requests.created", request_record)
          render json: { assistance_request: { id: request_record.id, status: request_record.status } }, status: :created
        rescue ActionController::BadRequest
          render_error("invalid_assistance_request", :unprocessable_entity)
        end

        def contact
          form = ::Account::ContactTempleRequestForm.new(params: contact_params)
          return render_validation_errors(form) unless form.valid?
          result = Contact::TempleInquirySender.new(user: current_native_user, temple: current_native_temple, subject: form.subject, message: form.message, request_id: request.request_id, ip: request.remote_ip).call
          return render_error("contact_delivery_failed", :unprocessable_entity) unless result.success?
          audit!("account.contact_temple_requests.created", current_native_user)
          render json: { accepted: true }, status: :created
        end

        private

        def assistance_params
          params.fetch(:assistance, {}).permit(:registration_id, :channel, :message)
        end

        def registration_for_assistance
          registration_id = assistance_params[:registration_id].presence
          return nil if registration_id.blank?
          current_native_user.temple_event_registrations.find_by!(id: registration_id, temple_id: current_native_temple.id)
        end

        def contact_params
          params.fetch(:contact, {}).permit(:subject, :message, :website)
        end

        def audit!(action, target)
          SystemAuditLogger.log!(action:, admin: current_native_user, target:, temple: current_native_temple, metadata: { actor_type: "user", source: "native_account_api" })
        end
      end
    end
  end
end
