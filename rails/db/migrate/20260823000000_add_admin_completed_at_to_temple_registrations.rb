# frozen_string_literal: true

class AddAdminCompletedAtToTempleRegistrations < ActiveRecord::Migration[7.1]
  def change
    add_column :temple_registrations, :admin_completed_at, :datetime
  end
end
