class CreateRosterContainers < ActiveRecord::Migration
  def change
    create_table :roster_containers do |t|
      t.uuid :uuid,           null: false, index: { unique: true }
      t.uuid :roster_uuid,    null: false,
                              foreign_key: { to_table: :course_rosters, to_column: :uuid }
      t.uuid :container_uuid, null: false, index: true,
                              foreign_key: { to_table: :course_containers, to_column: :uuid }
      t.uuid :parent_roster_container_uuid,
             index: true,
             foreign_key: { to_table: :roster_containers, to_column: :uuid }
      t.boolean :is_archived, null: false

      t.timestamps                   null: false
    end

    add_index :roster_containers, [:roster_uuid, :container_uuid], unique: true
  end
end
