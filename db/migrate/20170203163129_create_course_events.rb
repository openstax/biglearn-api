class CreateCourseEvents < ActiveRecord::Migration
  def change
    create_table :course_events do |t|
      t.uuid    :uuid,            null: false, index: { unique: true }
      t.uuid    :course_uuid,     null: false
      t.integer :sequence_number, null: false
      t.integer :event_type,      null: false
      t.jsonb   :data,            null: false

      t.timestamps                null: false
    end

    add_index :course_events, [:sequence_number, :course_uuid], unique: true
    add_index :course_events, [:course_uuid, :event_type]
  end
end
