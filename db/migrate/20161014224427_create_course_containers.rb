class CreateCourseContainers < ActiveRecord::Migration
  def change
    create_table :course_containers, id: false do |t|
      t.uuid :container_uuid, null: false
      t.uuid :parent_container_uuid, null: false
      t.uuid :course_uuid,
             foreign_key: { to_table: :courses, to_column: :uuid },
             null: false, index: true
    end
  end
end
