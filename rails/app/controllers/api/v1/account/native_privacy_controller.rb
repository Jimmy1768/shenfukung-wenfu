# frozen_string_literal: true

module Api
  module V1
    module Account
      class NativePrivacyController < NativeBaseController
        def show
          render json: { privacy_requests: current_native_user.privacy_requests.order(requested_at: :desc).map { |record| { id: record.id, request_type: record.request_type, status: record.status, requested_at: record.requested_at } } }
        end

        def request_action
          type = params[:request_type].to_s
          return render_error("invalid_privacy_request", :unprocessable_entity) unless %w[data_deletion data_export].include?(type)
          return render_error("privacy_request_already_open", :unprocessable_entity) if current_native_user.privacy_requests.open_requests.exists?(request_type: type)

          record = current_native_user.privacy_requests.create!(request_type: type, status: "pending", submitted_via: "expo", requested_at: Time.current)
          current_native_user.account_lifecycle_events.create!(event_type: "privacy_request_submitted", occurred_at: Time.current, user_name_snapshot: current_native_user.native_name.presence || current_native_user.english_name.presence || current_native_user.email, metadata: { "request_type" => type })
          audit!("account.privacy.requested", record)
          render json: { privacy_request: { id: record.id, request_type: record.request_type, status: record.status } }, status: :created
        end

        def close
          ActiveRecord::Base.transaction do
            record = current_native_user.privacy_requests.create!(request_type: "account_closure", status: "completed", submitted_via: "expo", requested_at: Time.current, resolved_at: Time.current, metadata: { "reason" => "self_service" })
            current_native_user.close_account!(reason: "self_service")
            audit!("account.privacy.account_closed", record)
          end
          head :no_content
        end

        private

        def audit!(action, target)
          SystemAuditLogger.log!(action:, admin: current_native_user, target:, temple: current_native_temple, metadata: { actor_type: "user", source: "native_account_api" })
        end
      end
    end
  end
end
