class CreateCourses < ActiveRecord::Migration[5.0]
  def change
    create_table :courses do |t|
      t.uuid    :uuid,                     null: false, index: { unique: true }
      t.integer :metadata_sequence_number, null: false, index: { unique: true }
      t.integer :sequence_number,          null: false, index: true
      t.uuid    :initial_ecosystem_uuid

      t.timestamps                         null: false
    end

    create_function :next_course_metadata_sequence_number

    change_column_default :courses, :metadata_sequence_number, -> do
      'next_course_metadata_sequence_number()'
    end

    reversible do |dir|
      dir.up do
        Course.reset_column_information

        create_course_data_by_course_uuid = CourseEvent.create_course
                                                       .pluck(:course_uuid, :data)
                                                       .to_h

        CourseEvent
          .group(:course_uuid)
          .order('MIN("created_at")')
          .pluck(:course_uuid, 'MAX("sequence_number")')
          .each do |course_uuid, sequence_number|
          data = (create_course_data_by_course_uuid[course_uuid] || {}).symbolize_keys

          Course.create!(
            uuid: course_uuid,
            sequence_number: sequence_number + 1,
            initial_ecosystem_uuid: data[:ecosystem_uuid]
          )
        end
      end
    end
  end
end
