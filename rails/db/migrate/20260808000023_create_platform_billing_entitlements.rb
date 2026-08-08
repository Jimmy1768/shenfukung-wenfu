class CreatePlatformBillingEntitlements < ActiveRecord::Migration[7.1]
  def change
    create_table :platform_billing_entitlements do |t|
      t.references :temple, null: false, foreign_key: true, index: { unique: true }
      t.string :state, null: false, default: "pending_setup"
      t.datetime :adopted_at, null: false
      t.datetime :activated_at
      t.datetime :suspended_at
      t.datetime :transitioned_at, null: false
      t.references :platform_billing_delivery, foreign_key: true
      t.references :platform_billing_event, foreign_key: true
      t.timestamps
    end

    add_check_constraint :platform_billing_entitlements,
      "state IN ('pending_setup', 'active', 'suspended')",
      name: "platform_billing_entitlements_state_check"
  end
end
