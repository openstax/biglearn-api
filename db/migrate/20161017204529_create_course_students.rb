class CreateCourseStudents < ActiveRecord::Migration
  def change
    create_table :course_students do |t|
      t.uuid :student_uuid, null: false, index: true
      t.uuid :container_uuid, null: false,
             foreign_key: { to_table: 'course_containers', to_column: 'container_uuid' }
    end
    add_index :course_students, [:student_uuid, :container_uuid], unique: true
  end
end
