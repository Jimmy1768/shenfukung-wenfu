require "test_helper"
require Rails.root.join("db", "seeds", "temples").to_s

class AdminOfferingOrdersRegistrantFlowTest < ActionDispatch::IntegrationTest
  setup do
    @temple = create_temple
    @admin = create_admin_user(temple: @temple)
    permission = AdminPermission.find_by(admin_account: @admin.admin_account, temple: @temple)
    permission.update!(manage_registrations: true)

    @gathering = @temple.temple_gatherings.create!(
      slug: "community-satsang",
      title: "Community Satsang",
      currency: "TWD",
      price_cents: 0,
      status: "published"
    )
    @event = TempleOffering.create!(
      temple: @temple,
      slug: "spring-rite",
      title: "Spring Rite",
      starts_on: Date.current,
      ends_on: Date.current + 1.day,
      offering_type: "general",
      currency: "TWD",
      price_cents: 1000
    )
    @patron = User.create!(
      email: "household@example.com",
      english_name: "Household Owner",
      encrypted_password: User.password_hash("Password123!")
    )
    @other_patron = User.create!(
      email: "other-household@example.com",
      english_name: "Other Household",
      encrypted_password: User.password_hash("Password123!")
    )
    @dependent = create_dependent_for(@patron, name: "Family Member")
    @other_dependent = create_dependent_for(@other_patron, name: "Other Family")
  end

  test "admin creates dependent registration and stores registrant metadata" do
    @temple.adopt_platform_billing_entitlement!.update!(state: "active")
    sign_in_admin(@admin)

    assert_difference -> { @temple.temple_event_registrations.count }, 1 do
      post admin_gathering_offering_orders_path(@gathering), params: {
        temple_event_registration: {
          user_id: @patron.id,
          quantity: 1,
          registrant_scope: "dependent",
          dependent_id: @dependent.id
        }
      }
    end

    registration = @temple.temple_event_registrations.order(created_at: :desc).first
    assert_redirected_to admin_gathering_offering_order_path(@gathering, registration)
    assert_equal "dependent", registration.metadata["registrant_scope"]
    assert_equal @dependent.id.to_s, registration.metadata["dependent_id"]
    assert_equal "Family Member", registration.metadata["registrant_name"]

    get admin_gathering_offering_orders_path(@gathering)
    assert_response :success
    assert_includes response.body, "Family Member"
  end

  test "admin new and edit event registration screens render real submittable forms" do
    @temple.adopt_platform_billing_entitlement!.update!(state: "active")
    sign_in_admin(@admin)

    get new_admin_event_offering_order_path(@event)
    assert_response :success
    assert_select "form[data-registration-form]" do |forms|
      form = forms.first
      assert_equal admin_event_offering_orders_path(@event), form["action"]
      assert_equal "post", form["method"]
    end
    assert_select "input#temple_event_registration_user_id"
    assert_select "input[type=submit]", 1

    assert_difference -> { @event.temple_event_registrations.count }, 1 do
      post admin_event_offering_orders_path(@event), params: {
        temple_event_registration: {
          user_id: @patron.id,
          quantity: 1,
          registrant_scope: "self",
          contact_details: { primary_contact: "Household Owner", email: @patron.email },
          logistics_details: { arrival_window: "morning" }
        }
      }
    end
    registration = @event.temple_event_registrations.order(:id).last
    assert_redirected_to admin_event_offering_order_path(@event, registration)

    get edit_admin_event_offering_order_path(@event, registration)
    assert_response :success
    assert_select "form[data-registration-form]" do |forms|
      form = forms.first
      assert_equal admin_event_offering_order_path(@event, registration), form["action"]
    end
    assert_select "input[name='temple_event_registration[logistics_details][arrival_window]'][value='morning']", 1

    patch admin_event_offering_order_path(@event, registration), params: {
      temple_event_registration: {
        user_id: @patron.id,
        quantity: 2,
        registrant_scope: "self",
        contact_details: { primary_contact: "Household Owner", email: @patron.email },
        logistics_details: { arrival_window: "afternoon" }
      }
    }
    assert_redirected_to admin_event_offering_order_path(@event, registration)
    registration.reload
    assert_equal 2, registration.quantity
    assert_equal "afternoon", registration.logistics_payload["arrival_window"]

    get admin_event_offering_order_path(@event, registration)
    assert_response :success
  end

  test "admin self and dependent create and eligible update write identical scoped defaults" do
    @temple.adopt_platform_billing_entitlement!.update!(state: "active")
    @event.update!(metadata: {
      "registration_form" => {
        "sections" => { "logistics" => ["arrival_window"], "ritual_metadata" => ["incense_option"] },
        "field_settings" => { "incense_option" => { "allow_multiple" => true } }
      }
    })
    sign_in_admin(@admin)
    defaults = Registrations::ReusableDefaults.new(user: @patron, temple: @temple, offering: @event)

    post admin_event_offering_orders_path(@event), params: {
      temple_event_registration: { user_id: @patron.id, quantity: 1, registrant_scope: "self", logistics_details: { arrival_window: "morning" }, ritual_metadata: { incense_option: "lotus" } }
    }
    self_registration = @event.temple_event_registrations.order(:id).last
    assert_redirected_to admin_event_offering_order_path(@event, self_registration)
    @patron.reload
    assert_equal({ "arrival_window" => "morning", "incense_option" => ["lotus"] }, defaults.read)

    patch admin_event_offering_order_path(@event, self_registration), params: {
      temple_event_registration: { user_id: @patron.id, quantity: 1, registrant_scope: "self", logistics_details: { arrival_window: "afternoon" }, ritual_metadata: { incense_option: "rose" } }
    }
    assert_redirected_to admin_event_offering_order_path(@event, self_registration)
    @patron.reload
    assert_equal({ "arrival_window" => "afternoon", "incense_option" => ["lotus", "rose"] }, defaults.read)

    post admin_event_offering_orders_path(@event), params: {
      temple_event_registration: { user_id: @patron.id, quantity: 1, registrant_scope: "dependent", dependent_id: @dependent.id, contact_details: { primary_contact: "Family Member", phone: "0933" }, logistics_details: { arrival_window: "evening" }, ritual_metadata: { incense_option: "jasmine" } }
    }
    dependent_registration = @event.temple_event_registrations.order(:id).last
    assert_redirected_to admin_event_offering_order_path(@event, dependent_registration)
    @patron.reload
    assert_equal({ "arrival_window" => "evening", "incense_option" => ["lotus", "rose", "jasmine"] }, defaults.read)
    assert_equal "0933", @dependent.reload.metadata["phone"]

    patch admin_event_offering_order_path(@event, dependent_registration), params: {
      temple_event_registration: { user_id: @patron.id, quantity: 1, registrant_scope: "dependent", dependent_id: @dependent.id, logistics_details: { arrival_window: "night" } }
    }
    assert_redirected_to admin_event_offering_order_path(@event, dependent_registration)
    @patron.reload
    assert_equal "night", defaults.read["arrival_window"]
  end

  test "admin duplicate and noneditable lifecycle paths do not mutate defaults" do
    @temple.adopt_platform_billing_entitlement!.update!(state: "active")
    @event.update!(metadata: { "registration_form" => { "sections" => { "logistics" => ["arrival_window"], "ritual_metadata" => [] } } })
    sign_in_admin(@admin)
    defaults = Registrations::ReusableDefaults.new(user: @patron, temple: @temple, offering: @event)
    defaults.write!("arrival_window" => "kept")
    existing = create_registration(user: @patron, offering: @event, metadata: { "registrant_scope" => "self" })

    post admin_event_offering_orders_path(@event), params: {
      temple_event_registration: { user_id: @patron.id, quantity: 1, registrant_scope: "self", logistics_details: { arrival_window: "duplicate" } }
    }
    assert_redirected_to admin_event_offering_order_path(@event, existing)
    assert_equal "kept", defaults.read["arrival_window"]

    [
      { payment_status: "paid", fulfillment_status: "open" },
      { payment_status: "refunded", fulfillment_status: "open" },
      { payment_status: "pending", fulfillment_status: "fulfilled" },
      { payment_status: "pending", fulfillment_status: "cancelled" }
    ].each do |state|
      registration = create_registration(user: @patron, offering: @event, metadata: { "registrant_scope" => "dependent", "dependent_id" => @dependent.id.to_s }, **state)
      patch admin_event_offering_order_path(@event, registration), params: {
        temple_event_registration: { logistics_details: { arrival_window: "must not write" } }
      }
      assert_redirected_to admin_event_offering_order_path(@event, registration)
      assert_equal "kept", defaults.read["arrival_window"]
    end

    locked = create_registration(user: @patron, offering: @event, metadata: { "registrant_scope" => "dependent", "dependent_id" => @dependent.id.to_s })
    create_payment(registration: locked, status: TemplePayment::STATUSES[:pending])
    patch admin_event_offering_order_path(@event, locked), params: {
      temple_event_registration: { logistics_details: { arrival_window: "locked must not write" } }
    }
    assert_redirected_to admin_event_offering_order_path(@event, locked)
    assert_equal "kept", defaults.read["arrival_window"]

    gathering = @temple.temple_gatherings.create!(
      slug: "read-only-#{SecureRandom.hex(3)}",
      title: "Read only gathering",
      status: "published",
      price_cents: 0,
      currency: "TWD",
      metadata: { "registration_form" => { "sections" => { "logistics" => ["arrival_window"], "ritual_metadata" => [] } } }
    )
    gathering_defaults = Registrations::ReusableDefaults.new(user: @patron, temple: @temple, offering: gathering)
    gathering_defaults.write!("arrival_window" => "gathering kept")
    read_only = create_registration(user: @patron, offering: gathering, metadata: { "registrant_scope" => "self" })
    patch admin_gathering_offering_order_path(gathering, read_only), params: {
      temple_event_registration: { logistics_details: { arrival_window: "read only must not write" } }
    }
    assert_redirected_to admin_gathering_offering_order_path(gathering, read_only)
    assert_equal "gathering kept", gathering_defaults.read["arrival_window"]
  end

  test "admin reusable-value editor only clears configured values in the current offering scope" do
    @event.update!(metadata: {
      "registration_form" => {
        "sections" => { "logistics" => ["arrival_window"], "ritual_metadata" => ["incense_option"] },
        "field_settings" => { "incense_option" => { "allow_multiple" => true } }
      }
    })
    sign_in_admin(@admin)
    defaults = Registrations::ReusableDefaults.new(user: @patron, temple: @temple, offering: @event)
    defaults.write!("arrival_window" => "morning", "incense_option" => "lotus")

    delete admin_patron_metadata_value_path(@patron, "arrival_window"), params: { field: "arrival_window", offering_kind: "event", offering_id: @event.id }
    assert_response :success
    @patron.reload
    assert_equal({ "incense_option" => ["lotus"] }, defaults.read)

    post admin_patron_metadata_values_path(@patron), params: { field: "quantity", value: "2", offering_kind: "event", offering_id: @event.id }
    assert_response :unprocessable_content
    @patron.reload
    assert_equal({ "incense_option" => ["lotus"] }, defaults.read)

    delete admin_patron_metadata_value_path(@patron, "incense_option"), params: { field: "incense_option", value: "lotus", offering_kind: "event", offering_id: @event.id }
    assert_response :success
    @patron.reload
    assert_equal({}, defaults.read)
  end

  test "admin patron search provides only safe defaults for the exact offering" do
    @event.update!(metadata: { "registration_form" => { "sections" => { "logistics" => ["arrival_window"], "ritual_metadata" => [] } } })
    defaults = Registrations::ReusableDefaults.new(user: @patron, temple: @temple, offering: @event)
    defaults.write!("arrival_window" => "safe prefill")
    @patron.reload
    @patron.update!(metadata: @patron.metadata.merge("offerings" => { @event.slug => { "arrival_window" => "legacy must not prefill" } }))
    sign_in_admin(@admin)

    get admin_patrons_path(format: :json, q: @patron.email, offering_kind: "event", offering_id: @event.id)
    assert_response :success
    patron = response.parsed_body.fetch("patrons").find { |entry| entry.fetch("id") == @patron.id }
    assert_equal({ "arrival_window" => "safe prefill" }, patron.fetch("registration_defaults"))
    refute patron.key?("offerings")
  end

  test "expired billing grace lets a new admin registration through, pending" do
    @temple.update!(
      payment_provider_settings: {
        "billing" => {
          "payment_method_on_file" => false,
          "monthly_fee_cents" => 500_000,
          "grace_days" => 30,
          "grace_started_at" => 31.days.ago.iso8601
        }
      }
    )

    sign_in_admin(@admin)

    # Intake is never blocked, frozen billing or not -- staff can always
    # take a walk-in. Only the payment step (Admin::PaymentsController,
    # Payments::CashPaymentRecorder) is gated on billing status.
    assert_difference -> { @temple.temple_event_registrations.count }, 1 do
      post admin_gathering_offering_orders_path(@gathering), params: {
        temple_event_registration: {
          user_id: @patron.id,
          quantity: 1,
          registrant_scope: "self"
        }
      }
    end

    registration = @temple.temple_event_registrations.order(:created_at).last
    assert_redirected_to admin_gathering_offering_order_path(@gathering, registration)
    assert_equal TempleRegistration::PAYMENT_STATUSES[:pending], registration.payment_status
  end

  test "pending setup and suspended entitlements let admin registrations through, pending" do
    entitlement = @temple.adopt_platform_billing_entitlement!
    sign_in_admin(@admin)

    ["pending_setup", "suspended"].each do |state|
      entitlement.update!(state:)
      # A distinct gathering per state: the same patron registering twice
      # for the same gathering is a separate duplicate-prevention rule,
      # not something this test is about.
      gathering = @temple.temple_gatherings.create!(
        slug: "community-satsang-#{state}",
        title: "Community Satsang #{state}",
        currency: "TWD",
        price_cents: 0,
        status: "published"
      )

      assert_difference -> { @temple.temple_event_registrations.count }, 1 do
        post admin_gathering_offering_orders_path(gathering), params: {
          temple_event_registration: { user_id: @patron.id, quantity: 1, registrant_scope: "self" }
        }
      end

      registration = @temple.temple_event_registrations.order(:created_at).last
      assert_redirected_to admin_gathering_offering_order_path(gathering, registration)
      assert_equal TempleRegistration::PAYMENT_STATUSES[:pending], registration.payment_status
    end
  end

  test "admin create redirects to existing registration for same dependent scope" do
    existing = create_registration(
      user: @patron,
      offering: @gathering,
      metadata: {
        "registrant_scope" => "dependent",
        "dependent_id" => @dependent.id.to_s,
        "registrant_name" => "Family Member"
      },
      contact_payload: { "primary_contact" => "Family Member" }
    )

    sign_in_admin(@admin)

    assert_no_difference -> { @temple.temple_event_registrations.count } do
      post admin_gathering_offering_orders_path(@gathering), params: {
        temple_event_registration: {
          user_id: @patron.id,
          quantity: 1,
          registrant_scope: "dependent",
          dependent_id: @dependent.id
        }
      }
    end

    assert_redirected_to admin_gathering_offering_order_path(@gathering, existing)
  end

  test "gathering registrations cannot be edited after creation" do
    registration = create_registration(
      user: @patron,
      offering: @gathering,
      metadata: { "registrant_scope" => "self" }
    )

    sign_in_admin(@admin)

    get admin_gathering_offering_order_path(@gathering, registration)
    assert_response :success
    assert_no_match(/Edit attendance/, response.body)

    get edit_admin_gathering_offering_order_path(@gathering, registration)
    assert_redirected_to admin_gathering_offering_order_path(@gathering, registration)
  end

  test "admin pending registration allows core field edits" do
    registration = create_registration(
      user: @patron,
      offering: @event,
      quantity: 1,
      unit_price_cents: 1000,
      total_price_cents: 1000,
      currency: "TWD",
      metadata: {
        "registrant_scope" => "dependent",
        "dependent_id" => @dependent.id.to_s,
        "registrant_name" => @dependent.english_name
      }
    )

    sign_in_admin(@admin)

    patch admin_event_offering_order_path(@event, registration), params: {
      temple_event_registration: {
        user_id: @other_patron.id,
        quantity: 9,
        unit_price_cents: 2500,
        currency: "USD",
        registrant_scope: "dependent",
        dependent_id: @other_dependent.id,
        logistics_details: { preferred_slot: "Afternoon" }
      }
    }

    assert_redirected_to admin_event_offering_order_path(@event, registration)
    registration.reload
    assert_equal @other_patron.id, registration.user_id
    assert_equal 9, registration.quantity
    assert_equal 2500, registration.unit_price_cents
    assert_equal "USD", registration.currency
    assert_equal @other_dependent.id.to_s, registration.metadata["dependent_id"]
    assert_equal "dependent", registration.metadata["registrant_scope"]
    assert_equal "Other Family", registration.metadata["registrant_name"]
    assert_equal "Afternoon", registration.logistics_payload["preferred_slot"]
  end

  test "admin paid registration blocks core field edits but keeps metadata editable" do
    registration = create_registration(
      user: @patron,
      offering: @event,
      quantity: 1,
      unit_price_cents: 1000,
      total_price_cents: 1000,
      currency: "TWD",
      metadata: {
        "registrant_scope" => "dependent",
        "dependent_id" => @dependent.id.to_s,
        "registrant_name" => @dependent.english_name
      }
    )
    create_payment(registration: registration)

    sign_in_admin(@admin)

    patch admin_event_offering_order_path(@event, registration), params: {
      temple_event_registration: {
        user_id: @other_patron.id,
        quantity: 9,
        unit_price_cents: 2500,
        currency: "USD",
        registrant_scope: "dependent",
        dependent_id: @other_dependent.id,
        contact_details: { primary_contact: "Changed After Paid" },
        logistics_details: { preferred_slot: "Evening" }
      }
    }

    assert_redirected_to admin_event_offering_order_path(@event, registration)
    registration.reload
    assert_equal @patron.id, registration.user_id
    assert_equal 1, registration.quantity
    assert_equal 1000, registration.unit_price_cents
    assert_equal "TWD", registration.currency
    assert_equal @dependent.id.to_s, registration.metadata["dependent_id"]
    assert_equal "dependent", registration.metadata["registrant_scope"]
    assert_not_equal "Changed After Paid", registration.contact_payload["primary_contact"]
    assert_equal "Evening", registration.logistics_payload["preferred_slot"]
  end

  test "admin pending update keeps duplicate guard on registrant identity" do
    registration = create_registration(
      user: @patron,
      offering: @event,
      metadata: { "registrant_scope" => "self" }
    )
    existing = create_registration(
      user: @patron,
      offering: @event,
      metadata: {
        "registrant_scope" => "dependent",
        "dependent_id" => @dependent.id.to_s,
        "registrant_name" => "Family Member"
      }
    )

    sign_in_admin(@admin)

    patch admin_event_offering_order_path(@event, registration), params: {
      temple_event_registration: {
        user_id: @patron.id,
        registrant_scope: "dependent",
        dependent_id: @dependent.id
      }
    }

    assert_redirected_to admin_event_offering_order_path(@event, existing)
    registration.reload
    assert_equal "self", registration.metadata["registrant_scope"]
    assert_nil registration.metadata["dependent_id"]
  end

  test "synthetic configured service supports admin order creation without publishing the offering" do
    Seeds::Temples.bootstrap(slug: "readiness-synthetic")
    synthetic_temple = Temple.find_by!(slug: "readiness-synthetic")
    Offerings::TemplateParity.ensure_missing!(synthetic_temple, kinds: [:services])
    service = synthetic_temple.temple_services.find_by!(slug: "readiness-peace-lamp")
    admin = create_admin_user(temple: synthetic_temple)
    permission = AdminPermission.find_by(admin_account: admin.admin_account, temple: synthetic_temple)
    permission.update!(manage_registrations: true)
    user = User.create!(
      email: "synthetic-service-admin-order@example.com",
      english_name: "Synthetic Service Admin Order",
      encrypted_password: User.password_hash("Password123!")
    )

    sign_in_admin(admin)

    assert_difference -> { synthetic_temple.temple_event_registrations.count }, 1 do
      post admin_service_offering_orders_path(service), params: {
        temple_event_registration: {
          user_id: user.id,
          quantity: 1,
          registrant_scope: "self"
        }
      }
    end

    registration = synthetic_temple.temple_event_registrations.order(created_at: :desc).first
    assert_redirected_to admin_service_offering_order_path(service, registration)
    assert_equal service, registration.registrable
    assert_equal "pending", registration.payment_status
    assert_equal "self", registration.metadata["registrant_scope"]
  end

  test "eligible dependent-scoped update routes contact sync through the shared service" do
    @temple.adopt_platform_billing_entitlement!.update!(state: "active")
    sign_in_admin(@admin)
    registration = create_registration(user: @patron, offering: @event, metadata: { "registrant_scope" => "dependent", "dependent_id" => @dependent.id.to_s })

    calls = []
    tracker = ->(**kwargs) { calls << kwargs }

    Registrations::DependentContactSync.stub(:call!, tracker) do
      patch admin_event_offering_order_path(@event, registration), params: {
        temple_event_registration: {
          user_id: @patron.id,
          quantity: 1,
          registrant_scope: "dependent",
          dependent_id: @dependent.id,
          contact_details: { primary_contact: "Family Member", phone: "0988888888", email: "family-edit@example.com", dependents_notes: "shellfish allergy" }
        }
      }
    end

    assert_redirected_to admin_event_offering_order_path(@event, registration)
    assert_equal 1, calls.size, "expected the shared DependentContactSync service to be invoked exactly once"
    assert_equal @dependent, calls.first[:dependent]
    assert_equal "0988888888", calls.first[:phone]
    assert_equal "family-edit@example.com", calls.first[:email]
    assert_equal "shellfish allergy", calls.first[:notes]
  end

  test "self-scoped update never invokes the dependent contact sync service" do
    @temple.adopt_platform_billing_entitlement!.update!(state: "active")
    sign_in_admin(@admin)
    registration = create_registration(user: @patron, offering: @event, metadata: { "registrant_scope" => "self" })

    calls = []
    tracker = ->(**kwargs) { calls << kwargs }

    Registrations::DependentContactSync.stub(:call!, tracker) do
      patch admin_event_offering_order_path(@event, registration), params: {
        temple_event_registration: {
          user_id: @patron.id,
          quantity: 1,
          registrant_scope: "self",
          contact_details: { primary_contact: "Household Owner", email: @patron.email }
        }
      }
    end

    assert_redirected_to admin_event_offering_order_path(@event, registration)
    assert_empty calls
  end

  private

  def create_dependent_for(user, name:)
    dependent = Dependent.create!(english_name: name)
    UserDependent.create!(
      user: user,
      dependent: dependent,
      role: "family",
      relationship_label: "Family"
    )
    dependent
  end
end
