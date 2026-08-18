# frozen_string_literal: true

module Admin
  class PatronMetadataValuesController < BaseController
    before_action :require_manage_registrations!
    before_action :set_patron
    before_action :set_offering

    def create
      field = params.require(:field).to_s
      value = params.require(:value).to_s.strip
      raise ArgumentError, "Value can't be blank" if value.blank?
      raise ArgumentError, "Field is not reusable for this offering" unless reusable_defaults.eligible_field?(field)

      values =
        if offering_schema.allow_multiple?(field)
          reusable_defaults.add!(field:, value:)
        else
          reusable_defaults.write!(field => value)
        end
      audit!("add", field)

      if browser_ui_request?
        redirect_to safe_return_to, notice: t("admin.registration_form.reusable_defaults.flash.added", field: reusable_field_label(field))
      else
        render json: { values: }, status: :created
      end
    rescue ArgumentError => e
      if browser_ui_request?
        redirect_to safe_return_to, alert: e.message
      else
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end

    def destroy
      field = params.require(:field).to_s
      value = params[:value].to_s.strip.presence
      values = reusable_defaults.clear!(field:, value:)
      audit!("clear", field)

      if browser_ui_request?
        redirect_to safe_return_to, notice: t("admin.registration_form.reusable_defaults.flash.cleared", field: reusable_field_label(field))
      else
        render json: { values: }
      end
    rescue ArgumentError => e
      if browser_ui_request?
        redirect_to safe_return_to, alert: e.message
      else
        render json: { error: e.message }, status: :unprocessable_entity
      end
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

    def offering_schema
      @offering_schema ||= Registrations::FormSchema.new(@offering.metadata["registration_form"])
    end

    def reusable_field_label(field)
      t("admin.registration_form.fields.#{field}", default: field.humanize)
    end

    # The admin namespace routes default to format: :html, so request format
    # negotiation alone can't tell the embedded admin UI form apart from a
    # direct JSON API caller. The embedded UI form always submits
    # `return_to` (it needs it to redirect back to the offering-orders
    # screen); a direct JSON API call never does.
    def browser_ui_request?
      params[:return_to].present?
    end

    def safe_return_to
      candidate = params[:return_to].to_s
      return admin_dashboard_path unless candidate.start_with?("/") && !candidate.start_with?("//")

      candidate
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
