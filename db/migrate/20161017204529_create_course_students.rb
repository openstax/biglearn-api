class CreateCourseStudents < ActiveRecord::Migration
  def change
    create_table :course_students do |t|
      t.uuid :student_uuid, null: false, index: true
      t.uuid :container_uuid, null: false, index: true
    end
    add_index :course_students, [:student_uuid, :container_uuid], unique: true
    add_foreign_key :course_students, :course_containers, column: :container_uuid, primary_key: :container_uuid
  end
end
