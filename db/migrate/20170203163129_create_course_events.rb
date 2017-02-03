class CreateCourseEvents < ActiveRecord::Migration
  def change
    create_table :course_events do |t|
      t.uuid    :uuid,            null: false, index: { unique: true }
      t.string  :type,            null: false
      t.uuid    :course_uuid,     null: false
      t.integer :sequence_number, null: false
      t.jsonb   :json,            null: false

      t.timestamps                null: false
    end

    add_index :course_events, [:course_uuid, :sequence_number], unique: true
  end
end
