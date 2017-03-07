class CreateStudentClues < ActiveRecord::Migration
  def change
    create_table :student_clues do |t|
      t.uuid   :uuid,                null: false, index: { unique: true }
      t.uuid   :student_uuid,        null: false
      t.uuid   :book_container_uuid, null: false, index: true
      t.string :algorithm_name,      null: false
      t.jsonb  :data,                null: false

      t.timestamps                   null: false
    end

    add_index :student_clues, [:student_uuid, :book_container_uuid, :algorithm_name],
                              unique: true,
                              name: 'index_student_clues_on_student_uuid_and_book_container_uuid'
  end
end
