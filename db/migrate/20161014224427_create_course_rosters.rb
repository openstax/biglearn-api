class CreateCourseRosters < ActiveRecord::Migration
  def change
    create_table :course_rosters do |t|
      t.uuid :uuid,               null: false, index: { unique: true }
      t.uuid :course_uuid,        null: false
      t.integer :sequence_number, null: false

      t.timestamps null: false
    end

    add_index :course_rosters, [:course_uuid, :sequence_number], unique: true
  end
end
