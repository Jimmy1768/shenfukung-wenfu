# frozen_string_literal: true

module Admin
  class PatronMetadataValuesController < BaseController
    before_action :require_manage_registrations!
    before_action :set_patron
    before_action :set_offering

    def create
      values = reusable_defaults.add!(field: params.require(:field), value: params.require(:value).to_s.strip)
      audit!("add", params.require(:field).to_s)
      render json: { values: }, status: :created
    rescue ArgumentError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def destroy
      value = params[:value].to_s.strip.presence
      values = reusable_defaults.clear!(field: params.require(:field), value:)
      audit!("clear", params.require(:field).to_s)
      render json: { values: }
    rescue ArgumentError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def set_patron
      @patron = User.find(params[:patron_id])
    end

    def require_manage_registrations!
      require_capability!(:manage_registrations)
    end

    def set_offering
      @offering =
        case params.require(:offering_kind).to_s
        when "service", "services", "TempleService"
          current_temple.temple_services.find(params.require(:offering_id))
        when "gathering", "gatherings", "TempleGathering"
          current_temple.temple_gatherings.find(params.require(:offering_id))
        when "event", "events", "TempleEvent"
          current_temple.temple_events.find(params.require(:offering_id))
        else
          raise ArgumentError, "Offering kind is invalid"
        end
    end

    def reusable_defaults
      @reusable_defaults ||= Registrations::ReusableDefaults.new(user: @patron, temple: current_temple, offering: @offering)
    end

    def audit!(operation, field)
      SystemAuditLogger.log!(
        action: "temple.registration_defaults.#{operation}",
        admin: current_admin,
        target: @patron,
        temple: current_temple,
        metadata: { offering_id: @offering.id, registrable_type: @offering.class.base_class.name, changed_reusable_fields: [field] }
      )
    end
  end
end
