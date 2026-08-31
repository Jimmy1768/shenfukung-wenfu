# frozen_string_literal: true

module Admin
  class PatronsController < BaseController
    before_action :require_patron_access!, only: :index
    before_action :require_manage_permissions!, only: %i[promote revoke oauth_duplicates]
    # Two different lookups on purpose.
    #
    # records/note read and write PATRON DATA, so they are restricted to people
    # this temple can actually see -- its own patrons and its own staff.
    #
    # promote/revoke manage ADMIN MEMBERSHIP, which is the staff-hiring flow: an
    # owner must be able to promote someone who has never registered at their
    # temple (see patron_picker_test "promote creates an admin membership for
    # the current temple"). Those stay an unrestricted lookup, gated instead by
    # require_manage_permissions!.
    before_action :set_addressable_patron, only: %i[records note]
    before_action :set_patron, only: %i[promote revoke]

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
      # `offering` is a method aliasing `registrable`, not an association --
      # `includes(:offering)` raised for any patron who actually had
      # registrations, which is every real patron. Preload the association.
      @registrations = patron_registrations.includes(:registrable, :temple_payments).order(created_at: :desc)
      @patron_note = TemplePatronNote.find_or_initialize_by(temple: current_temple, user: @patron)
    end

    # Staff-authored service context. Temple-scoped and never patron-visible;
    # see TemplePatronNote for why it is not one of the other two note kinds.
    def note
      require_patron_access!
      return if performed?

      body = params.require(:temple_patron_note).permit(:body).fetch(:body, "").to_s
      if body.length > TemplePatronNote::MAX_LENGTH
        return redirect_to records_admin_patron_path(@patron), alert: t("admin.patrons.notes.too_long", limit: TemplePatronNote::MAX_LENGTH)
      end

      record = TemplePatronNote.upsert_body!(
        temple: current_temple, user: @patron, body:, admin_account: current_admin&.admin_account
      )

      SystemAuditLogger.log!(
        action: "admin.patrons.note_updated",
        admin: current_admin,
        target: record,
        temple: current_temple,
        # The note body is deliberately not logged -- it is staff commentary
        # about a person, and the audit trail is a wider-read surface.
        metadata: { patron_id: @patron.id, cleared: record.blank_body? }
      )

      redirect_to records_admin_patron_path(@patron), notice: t("admin.patrons.notes.saved")
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

    # Membership is the binding itself: a signed-in patron who reaches this
    # temple -- by scanning its QR in the app, or selecting it on the web -- is
    # on its list from that moment. See TempleConnection.
    #
    # Registration is deliberately NOT the join. Treating it as one forced
    # anyone who needed to appear on a temple's list to buy an offering first,
    # which is absurd for staff who have worked there for years and is exactly
    # the friction this product is sold to remove.
    #
    # Before 2026-08-31 this was `User.all`, so every temple's staff could see
    # every account in the system -- including bare signups with no connection
    # to any temple -- by name and email. Invisible with one live tenant;
    # a cross-tenant disclosure the moment there are two.
    def patron_scope
      User.where(id: temple_patron_ids)
    end

    def temple_patron_ids
      TempleConnection.where(temple_id: current_temple.id).pluck(:user_id)
    end

    # Staff of this temple, whether or not they are also patrons of it. Kept
    # separate from patron_scope for exactly that reason: an admin who never
    # registered must still appear in the admins view.
    def temple_admin_ids
      AdminAccount
        .joins(:admin_temple_memberships)
        .where(admin_temple_memberships: { temple_id: current_temple.id })
        .pluck(:user_id)
    end

    # Who this admin may address by id at all. Scopes the member actions
    # (records, note, promote, revoke) so they cannot reach a stranger's
    # account through a guessed URL.
    def addressable_users
      User.where(id: temple_patron_ids | temple_admin_ids)
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

    # Starts from every user rather than patron_scope: the membership join
    # below is what scopes this view, and requiring patrons-of-this-temple too
    # would hide staff who never registered.
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
      User.all
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

    def set_addressable_patron
      @patron = addressable_users.find(params[:id])
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
