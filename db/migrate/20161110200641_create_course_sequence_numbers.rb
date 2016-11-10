class CreateCourseSequenceNumbers < ActiveRecord::Migration
  def change
    create_table :course_sequence_numbers do |t|
      t.uuid    :course_uuid,      null: false
      t.integer :sequence_number,  null: false
    end

    add_index :course_sequence_numbers,  :course_uuid,
                                         unique: true
  end
end
