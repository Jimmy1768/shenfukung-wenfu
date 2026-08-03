class CreatePlatformBillingDeliveryRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :platform_billing_deliveries do |t|
      t.references :temple, null: false, foreign_key: true
      t.references :platform_billing_statement, foreign_key: true
      t.string :kind, null: false
      t.string :status, null: false, default: "pending"
      t.datetime :period_start_at
      t.datetime :period_end_at
      t.string :pricing_policy_version
      t.string :currency, null: false, default: "TWD"
      t.integer :registration_count, null: false, default: 0
      t.integer :adjustment_total_cents, null: false, default: 0
      t.integer :total_cents, null: false, default: 0
      t.string :provider_customer_id
      t.string :provider_payment_method_id
      t.string :provider_reference
      t.string :idempotency_key, null: false
      t.datetime :due_at
      t.datetime :grace_deadline_at
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end
    add_index :platform_billing_deliveries, :platform_billing_statement_id, unique: true,
      name: "idx_platform_billing_deliveries_statement_unique"
    add_index :platform_billing_deliveries, :idempotency_key, unique: true
    add_index :platform_billing_deliveries, %i[temple_id kind]

    create_table :platform_billing_events do |t|
      t.references :temple, null: false, foreign_key: true
      t.references :platform_billing_delivery, foreign_key: true
      t.string :provider_event_id, null: false
      t.string :event_type, null: false
      t.jsonb :payload, null: false, default: {}
      t.timestamps
    end
    add_index :platform_billing_events, :provider_event_id, unique: true
  end
end
