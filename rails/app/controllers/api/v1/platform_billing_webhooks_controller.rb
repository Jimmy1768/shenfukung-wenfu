# frozen_string_literal: true

module Api
  module V1
    class PlatformBillingWebhooksController < ActionController::API
      def create
        secret = Billing::TemplemateStripeConfiguration.new.webhook_secret
        return head :unauthorized if secret.blank?
        return head :unauthorized if request.headers["Stripe-Signature"].blank?
        event = verified_event(secret)
        return if performed?
        record = Billing::StripePlatformBillingEventIngest.ingest!(event:)
        render json: { ok: true, event_id: record.id }
      rescue ArgumentError, ActiveRecord::RecordNotFound
        head :unprocessable_entity
      end

      private

      def verified_event(secret)
        Stripe::Webhook.construct_event(request.raw_post, request.headers["Stripe-Signature"], secret)
      rescue Stripe::SignatureVerificationError, ArgumentError
        head :unauthorized
        nil
      end
    end
  end
end
