class CreateRosterStudents < ActiveRecord::Migration
  def change
    create_table :roster_students do |t|
      t.uuid :uuid,           null: false, index: { unique: true }
      t.uuid :roster_uuid,    null: false,
                              foreign_key: { to_table: :course_rosters, to_column: :uuid }
      t.uuid :roster_container_uuid, null: false, index: true,
                                     foreign_key: { to_table: :roster_containers, to_column: :uuid }
      t.uuid :student_uuid,   null: false, index: true,
                              foreign_key: { to_table: :students, to_column: :uuid }

      t.timestamps            null: false
    end

    add_index :roster_students, [:roster_uuid, :student_uuid], unique: true
  end
end
