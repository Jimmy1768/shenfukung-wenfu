# frozen_string_literal: true

class CreateTemplePatronNotes < ActiveRecord::Migration[7.1]
  def change
    create_table :temple_patron_notes do |t|
      t.references :temple, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      # AdminAccount#table_name is "admins", not "admin_accounts".
      t.references :updated_by_admin_account, foreign_key: { to_table: :admins }
      t.text :body, null: false, default: ""
      t.timestamps
    end

    # Temple-scoped by construction: a User is global across tenants, so one
    # patron may be known to several temples. Each temple keeps its own note
    # and must never see another temple's.
    add_index :temple_patron_notes, %i[temple_id user_id], unique: true,
              name: "idx_temple_patron_notes_unique_per_temple"
  end
end
