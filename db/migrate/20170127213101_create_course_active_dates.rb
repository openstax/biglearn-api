class CreateCourseActiveDates < ActiveRecord::Migration
  def change
    create_table :course_active_dates do |t|
      t.uuid :uuid,               null: false, index: { unique: true }
      t.uuid :course_uuid,        null: false
      t.integer :sequence_number, null: false
      t.datetime :starts_at,      null: false
      t.datetime :ends_at,        null: false

      t.timestamps                null: false
    end

    add_index :course_active_dates, [:course_uuid, :sequence_number], unique: true
  end
end
