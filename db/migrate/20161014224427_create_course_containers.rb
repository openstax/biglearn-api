class CreateCourseContainers < ActiveRecord::Migration
  def change
    create_table :course_containers, id: false do |t|
      t.uuid :container_uuid, null: false, index: { unique: true }
      t.uuid :parent_container_uuid, null: false
      t.uuid :course_uuid,
             foreign_key: { to_table: :courses, to_column: :uuid },
             null: false, index: true
    end
    add_foreign_key :course_containers, :courses, column: :course_uuid, primary_key: :uuid
  end
end
