class CreateCourses < ActiveRecord::Migration[5.0]
  def change
    create_table :courses do |t|
      t.uuid    :uuid,                     null: false, index: { unique: true }
      t.uuid    :initial_ecosystem_uuid,   null: false
      t.integer :metadata_sequence_number, null: false, index: { unique: true }

      t.timestamps                         null: false
    end

    reversible do |dir|
      dir.up do
        course_values = CourseEvent.create_course
                                   .order(:created_at)
                                   .pluck(:course_uuid, :data)

        course_values.each do |course_uuid, data|
          Course.create!(
            uuid: course_uuid, initial_ecosystem_uuid: data.symbolize_keys.fetch(:ecosystem_uuid)
          )
        end
      end
    end
  end
end
