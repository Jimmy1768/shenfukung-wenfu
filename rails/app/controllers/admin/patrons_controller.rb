# frozen_string_literal: true

module Admin
  class PatronsController < BaseController
    before_action :require_patron_access!, only: :index
    before_action :require_manage_permissions!, only: %i[promote revoke oauth_duplicates]
    before_action :set_patron, only: %i[promote revoke records]

    def index
      patrons = filtered_scope

      respond_to do |format|
        format.html do
          @query = params[:q].to_s.strip.presence
          @view = permitted_view
          @patrons = patrons
            .includes(:dependents, admin_account: :admin_temple_memberships)
            .limit(25)
          @can_manage_admins = can_manage_admins?
        end
        format.json do
          render json: {
            patrons: patrons.limit(50).map { |user| patron_payload(user) }
          }
        end
      end
    end

    def promote
      manager.promote!(user: @patron, temple: current_temple, promoted_by: current_admin)
      redirect_to admin_patrons_path(view: params[:view], q: params[:q]), notice: t("admin.patrons.flash.promoted", name: @patron.english_name)
    rescue Admin::PatronAdminManager::Error => e
      redirect_to admin_patrons_path(view: params[:view], q: params[:q]), alert: e.message
    end

    def revoke
      manager.revoke!(user: @patron, temple: current_temple, revoked_by: current_admin)
      redirect_to admin_patrons_path(view: params[:view], q: params[:q]), notice: t("admin.patrons.flash.revoked", name: @patron.english_name)
    rescue Admin::PatronAdminManager::Error => e
      redirect_to admin_patrons_path(view: params[:view], q: params[:q]), alert: e.message
    end

    def records
      require_patron_access!
      @registrations = patron_registrations.includes(:offering, :temple_payments).order(created_at: :desc)
    end

    def oauth_duplicates
      unless oauth_account_linking_enabled?
        return redirect_to admin_patrons_path, alert: t("admin.patrons.oauth_duplicates.disabled")
      end

      @entries = Admin::OAuthDuplicateCandidatesReport.new.entries
    end

    private

    def require_manage_permissions!
      unless can_manage_admins?
        redirect_to admin_dashboard_path, alert: t("admin.patrons.flash.forbidden")
      end
    end

    def require_patron_access!
      return if can_manage_admins? || current_admin_permissions&.allow?(:manage_registrations)

      redirect_to admin_dashboard_path, alert: t("admin.patrons.flash.forbidden")
    end

    def patron_scope
      User.all
    end

    def filtered_scope
      scope = base_scope
      query = params[:q].to_s.strip
      return scope.order(created_at: :desc) if query.blank?

      tokens = query.split(/\s+/).presence || [query]

      conditions = tokens.each_with_index.map do |_, index|
        "(users.english_name ILIKE :token#{index} OR users.native_name ILIKE :token#{index} OR users.email ILIKE :token#{index})"
      end.join(" AND ")
      bindings = tokens.each_with_index.to_h do |token, index|
        ["token#{index}".to_sym, "%#{token}%"]
      end

      scope
        .where(conditions, bindings)
        .order(Arel.sql(sanitized_order_clause(tokens.first)))
    end

    def base_scope
      if permitted_view == "admins"
        admin_user_scope
      else
        patron_scope.where.not(id: current_admin&.id)
      end
    end

    def admin_user_scope
      # No .distinct: admin_temple_memberships has a unique index on
      # (admin_account_id, temple_id) and User has_one :admin_account, so
      # this join can never produce more than one row per user for a single
      # temple_id filter -- distinct was a no-op here, and a harmful one:
      # combined with the CASE-WHEN ORDER BY in sanitized_order_clause (only
      # built when a search query is present), Postgres rejects "SELECT
      # DISTINCT ... ORDER BY <expression not in select list>" outright,
      # which is exactly what broke this view's search and not the default
      # patron view's (which never had .distinct to begin with).
      patron_scope
        .joins(admin_account: :admin_temple_memberships)
        .where(admin_temple_memberships: { temple_id: current_temple.id })
    end

    def permitted_view
      view = params[:view].to_s
      %w[admins all].include?(view) ? view : "all"
    end

    def sanitized_order_clause(first_token)
      exact_match = "#{ActiveRecord::Base.sanitize_sql_like(first_token)}%"
      ApplicationRecord.send(
        :sanitize_sql_array,
        ["CASE WHEN users.english_name ILIKE :exact THEN 0 ELSE 1 END, users.english_name ASC NULLS LAST", { exact: exact_match }]
      )
    end

    def set_patron
      @patron = User.find(params[:id])
    end

    def patron_registrations
      current_temple
        .temple_registrations
        .where(user: @patron)
    end

    def manager
      @manager ||= Admin::PatronAdminManager.new
    end

    def can_manage_admins?
      current_admin&.admin_account&.owner_for_temple?(current_temple) || current_admin_permissions&.allow?(:manage_permissions)
    end

    helper_method :can_manage_admins?

    def patron_payload(user)
      dependent_entries = user.user_dependents.includes(:dependent).map do |link|
        dependent = link.dependent
        dependent_metadata = dependent&.metadata || {}
        {
          id: dependent.id,
          name: dependent.native_name.presence || dependent.english_name,
          phone: dependent_metadata["phone"],
          email: dependent_metadata["email"],
          notes: dependent_metadata["notes"],
          relationship: link.relationship_label.presence || dependent.relationship_label
        }
      end
      {
        id: user.id,
        name: user.english_name,
        email: user.email,
        dependents: dependent_entries.map { |entry| entry[:name] },
        dependent_entries: dependent_entries,
        # Staff-facing "how do we reach them": prefers the most recently
        # captured registration contact, falls back to the patron's profile.
        phone: Registrations::ReusableContact.read(user, :phone),
        notes: Registrations::ReusableContact.read(user, :notes),
        registration_defaults: reusable_defaults_for(user)
      }
    end

    def reusable_defaults_for(user)
      offering = offering_for_reusable_defaults
      return {} unless offering

      Registrations::ReusableDefaults.new(user:, temple: current_temple, offering:).read
    end

    def offering_for_reusable_defaults
      return @offering_for_reusable_defaults if defined?(@offering_for_reusable_defaults)

      @offering_for_reusable_defaults =
        case params[:offering_kind].to_s
        when "event", "events", "TempleEvent"
          current_temple.temple_events.find_by(id: params[:offering_id])
        when "service", "services", "TempleService"
          current_temple.temple_services.find_by(id: params[:offering_id])
        when "gathering", "gatherings", "TempleGathering"
          current_temple.temple_gatherings.find_by(id: params[:offering_id])
        end
    end

  end
end
