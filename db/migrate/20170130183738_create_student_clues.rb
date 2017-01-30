class CreateStudentClues < ActiveRecord::Migration
  def change
    create_table :student_clues do |t|
      t.uuid :uuid,                  null: false, index: { unique: true }
      t.uuid :student_uuid,          null: false
      t.uuid :book_container_uuid,   null: false, index: true
      t.decimal :aggregate,          null: false
      t.decimal :confidence_left,    null: false
      t.decimal :confidence_right,   null: false
      t.integer :sample_size,        null: false
      t.boolean :is_confidence_good, null: false
      t.boolean :is_level_high,      null: false
      t.boolean :is_above_threshold, null: false

      t.timestamps                   null: false
    end

    add_index :student_clues, [:student_uuid, :book_container_uuid], unique: true
  end
end
