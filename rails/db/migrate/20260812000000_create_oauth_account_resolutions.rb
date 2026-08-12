# frozen_string_literal: true

class CreateOAuthAccountResolutions < ActiveRecord::Migration[7.1]
  def change
    create_table :oauth_account_resolutions do |t|
      t.string :token_digest, null: false
      t.string :provider, null: false
      t.string :provider_uid, null: false
      t.string :email
      t.string :display_name
      t.boolean :email_verified
      t.string :surface, null: false, default: "account"
      t.string :purpose, null: false, default: "account_resolution"
      t.datetime :expires_at, null: false
      t.datetime :consumed_at
      t.string :consumed_mode
      t.bigint :consumed_by_user_id
      t.timestamps
    end

    add_index :oauth_account_resolutions, :token_digest, unique: true
    add_index :oauth_account_resolutions, :expires_at
    add_foreign_key :oauth_account_resolutions, :users, column: :consumed_by_user_id
    add_index :oauth_identities, %i[user_id provider], unique: true
  end
end
