# frozen_string_literal: true

# The native account API deliberately does not inherit Account::BaseController.
# That controller is a browser-cookie surface and includes admin-aware helpers.
module Api
  module V1
    module Account
      class NativeBaseController < ::Api::BaseController
        before_action :force_json_format
        before_action :resolve_native_temple!
        before_action :authenticate_native_user!

        rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
        rescue_from ActionController::ParameterMissing, with: :render_invalid_request

        private

        attr_reader :current_native_user, :current_native_temple, :current_native_session

        # Memoized per request: every native request is scoped to one temple,
        # so this must not be recomputed per registration row.
        def native_temple_delinquent?
          return @native_temple_delinquent if defined?(@native_temple_delinquent)

          @native_temple_delinquent = current_native_temple.payment_settlement_frozen?
        end

        def force_json_format
          request.format = :json
        end

        def resolve_native_temple!
          slug = params[:temple_slug].to_s.strip
          return render_error("tenant_required", :unprocessable_entity) if slug.blank?

          @current_native_temple = Temple.find_by(slug: slug)
          render_error("tenant_not_found", :not_found) unless @current_native_temple
        end

        def authenticate_native_user!
          return if performed?

          token = request.authorization.to_s.delete_prefix("Bearer ").presence
          payload = Auth::JwtService.decode(token)
          return render_error("session_invalid", :unauthorized) unless payload
          return render_error("session_invalid", :unauthorized) unless payload["scope"] == "account"

          user = User.find_by(id: payload["sub"] || payload["user_id"])
          session = user&.refresh_tokens&.find_by(id: payload["native_session_id"])
          if user.blank? || user.closed_account?
            return render_error("account_closed", :unauthorized)
          end
          return render_error("session_revoked", :unauthorized) unless session&.active?

          @current_native_user = user
          @current_native_session = session

          # Binding is the join. A signed-in patron reaching this temple --
          # via QR scan or a saved binding -- is what puts them on its list.
          TempleConnection.record!(user:, temple: @current_native_temple)
        end

        def issue_session_payload(user, context:)
          # The join moment. Every session-issuing path -- login, signup,
          # refresh, password reset, OAuth exchange and resolution -- lands
          # here, and none of them run authenticate_native_user!, so recording
          # only in that filter missed the binding until the *next* request.
          TempleConnection.record!(user:, temple: current_native_temple)

          result = Auth::RefreshToken.new(user).issue!(
            user_agent: request.user_agent,
            ip_address: request.remote_ip,
            context:
          )
          {
            access_token: Auth::JwtService.encode(
              { "sub" => user.id, "native_session_id" => result.record.id, "scope" => "account" }
            ),
            refresh_token: result.raw_token,
            token_type: "Bearer",
            expires_in: Auth::JwtConfig::ACCESS_TOKEN_TTL
          }
        end

        def native_context
          params.fetch(:device, {}).permit(:device_id, :device_name, :platform).to_h
        end

        def render_error(code, status, details: nil)
          payload = { error: code, code: code }
          payload[:details] = details if details.present?
          render json: payload, status: status
        end

        def render_validation_errors(record)
          render_error(
            "validation_failed",
            :unprocessable_entity,
            details: record.errors.to_hash.transform_values { |messages| Array(messages).map(&:to_s) }
          )
        end

        def render_not_found
          render_error("not_found", :not_found)
        end

        def render_invalid_request
          render_error("invalid_request", :unprocessable_entity)
        end

        # One shape for an offering across the native API. It lived in two
        # controllers with different field sets, so a field added to the list
        # never reached the registration screen -- which is how hero_image_url
        # came to exist in one and not the other. Requires the including
        # controller to have Account::RegistrationIntent for account_action_for.
        def offering_payload(record)
          {
            id: record.id,
            slug: record.slug,
            title: record.title,
            account_action: account_action_for(record),
            price_cents: record.try(:price_cents),
            currency: record.try(:currency),
            description: record.try(:description),
            # The offering's OWN picture only. Never the temple's 活動預設圖片:
            # in a list every image-less offering would carry the same
            # fallback, which is decoration rather than information and costs
            # the row height that pushes the register button off screen. The
            # detail page still falls back -- one large hero about one event is
            # worth showing even when it is the temple default.
            hero_image_url: record.try(:hero_image_url).presence,
            status: record.try(:timeline_status) || (record.try(:available?) ? "open" : nil)
          }.compact
        end
      end
    end
  end
end
