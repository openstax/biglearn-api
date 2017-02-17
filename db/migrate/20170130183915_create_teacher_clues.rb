class CreateTeacherClues < ActiveRecord::Migration
  def change
    create_table :teacher_clues do |t|
      t.uuid  :uuid,                  null: false, index: { unique: true }
      t.uuid  :course_container_uuid, null: false
      t.uuid  :book_container_uuid,   null: false, index: true
      t.jsonb :data,                  null: false

      t.timestamps                    null: false
    end

    add_index :teacher_clues, [:course_container_uuid, :book_container_uuid],
                              unique: true,
                              name: 'index_teacher_clues_on_course_cont_uuid_and_book_cont_uuid'
  end
end
