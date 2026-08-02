class CreatePlatformBillingRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :platform_billing_statements do |t|
      t.references :temple, null: false, foreign_key: true
      t.datetime :period_start_at, null: false
      t.datetime :period_end_at, null: false
      t.string :pricing_policy_version, null: false
      t.string :currency, null: false, default: "TWD"
      t.string :status, null: false, default: "closed"
      t.string :idempotency_key, null: false
      t.integer :registration_count, null: false, default: 0
      t.integer :included_registration_count, null: false, default: 0
      t.integer :band_one_registration_count, null: false, default: 0
      t.integer :band_two_registration_count, null: false, default: 0
      t.integer :band_three_registration_count, null: false, default: 0
      t.integer :base_fee_cents, null: false, default: 0
      t.integer :band_one_fee_cents, null: false, default: 0
      t.integer :band_two_fee_cents, null: false, default: 0
      t.integer :band_three_fee_cents, null: false, default: 0
      t.integer :usage_total_cents, null: false, default: 0
      t.integer :adjustment_total_cents, null: false, default: 0
      t.integer :total_cents, null: false, default: 0
      t.datetime :closed_at, null: false
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end

    add_index :platform_billing_statements, %i[temple_id period_start_at], unique: true,
      name: "idx_platform_billing_statements_period"
    add_index :platform_billing_statements, :idempotency_key, unique: true

    create_table :platform_billing_usage_records do |t|
      t.references :platform_billing_statement, null: false, foreign_key: true
      t.references :temple, null: false, foreign_key: true
      t.references :temple_registration, null: false, foreign_key: true
      t.datetime :registration_created_at, null: false
      t.integer :unit_fee_cents, null: false, default: 0
      t.jsonb :eligibility_snapshot, null: false, default: {}
      t.timestamps
    end

    add_index :platform_billing_usage_records,
      %i[platform_billing_statement_id temple_registration_id],
      unique: true,
      name: "idx_platform_billing_usage_records_statement_registration"
    add_index :platform_billing_usage_records, %i[temple_id temple_registration_id],
      name: "idx_platform_billing_usage_records_temple_registration"

    create_table :platform_billing_adjustments do |t|
      t.references :platform_billing_statement, null: false, foreign_key: true
      t.references :source_platform_billing_statement, null: false,
        foreign_key: { to_table: :platform_billing_statements }
      t.references :platform_billing_usage_record, null: false, foreign_key: true
      t.references :temple, null: false, foreign_key: true
      t.references :temple_registration, null: false, foreign_key: true
      t.string :reason, null: false
      t.integer :registration_count_delta, null: false, default: -1
      t.integer :amount_cents, null: false
      t.datetime :recognized_at, null: false
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end

    add_index :platform_billing_adjustments,
      %i[platform_billing_statement_id platform_billing_usage_record_id],
      unique: true,
      name: "idx_platform_billing_adjustments_statement_usage_record"

    add_index :temple_registrations, %i[temple_id created_at],
      name: "idx_temple_registrations_temple_created_at"
  end
end
