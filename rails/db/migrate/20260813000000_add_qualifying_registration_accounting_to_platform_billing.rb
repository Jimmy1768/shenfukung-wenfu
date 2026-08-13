class AddQualifyingRegistrationAccountingToPlatformBilling < ActiveRecord::Migration[7.1]
  def up
    add_column :platform_billing_usage_records, :qualifying_at, :datetime
    add_column :platform_billing_usage_records, :qualification_source, :string
    add_index :platform_billing_usage_records, %i[temple_id qualifying_at],
      name: "idx_platform_billing_usage_records_temple_qualifying_at"

    remove_index :platform_billing_usage_records,
      name: "idx_platform_billing_usage_records_temple_registration"
    add_index :platform_billing_usage_records, %i[temple_id temple_registration_id],
      unique: true,
      name: "idx_platform_billing_usage_records_temple_registration"

    remove_index :platform_billing_adjustments,
      name: "idx_platform_billing_adjustments_statement_usage_record"
    add_index :platform_billing_adjustments, :platform_billing_usage_record_id,
      unique: true,
      name: "idx_platform_billing_adjustments_usage_record"
  end

  def down
    remove_index :platform_billing_adjustments,
      name: "idx_platform_billing_adjustments_usage_record"
    add_index :platform_billing_adjustments,
      %i[platform_billing_statement_id platform_billing_usage_record_id],
      unique: true,
      name: "idx_platform_billing_adjustments_statement_usage_record"

    remove_index :platform_billing_usage_records,
      name: "idx_platform_billing_usage_records_temple_registration"
    add_index :platform_billing_usage_records, %i[temple_id temple_registration_id],
      name: "idx_platform_billing_usage_records_temple_registration"
    remove_index :platform_billing_usage_records,
      name: "idx_platform_billing_usage_records_temple_qualifying_at"
    remove_column :platform_billing_usage_records, :qualification_source
    remove_column :platform_billing_usage_records, :qualifying_at
  end
end
