class CreateCourseExerciseExclusions < ActiveRecord::Migration
  def change
    create_table :course_exercise_exclusions do |t|
      t.uuid    :uuid,                          null: false, index: { unique: true }
      t.uuid    :course_uuid,                   null: false
      t.integer :sequence_number,               null: false
      t.uuid    :excluded_exercise_uuids,       null: false, array: true
      t.uuid    :excluded_exercise_group_uuids, null: false, array: true

      t.timestamps                              null: false
    end

    add_index :course_exercise_exclusions,
              [:course_uuid, :sequence_number],
              unique: true,
              name: 'index_course_exercise_exclusions_on_c_uuid_and_s_number_uniq'
  end
end
