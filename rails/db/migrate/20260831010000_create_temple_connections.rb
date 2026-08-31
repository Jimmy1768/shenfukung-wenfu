# frozen_string_literal: true

class CreateTempleConnections < ActiveRecord::Migration[7.1]
  def change
    create_table :temple_connections do |t|
      t.references :temple, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :first_connected_at, null: false
      t.datetime :last_seen_at, null: false
      t.timestamps
    end

    add_index :temple_connections, %i[temple_id user_id], unique: true,
              name: "idx_temple_connections_unique"
  end
end
