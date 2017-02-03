class CreateAssignedExercises < ActiveRecord::Migration
  def change
    create_table :assigned_exercises do |t|
      t.uuid :uuid,            null: false, index: { unique: true }
      t.uuid :assignment_uuid, null: false, index: true
      t.uuid :trial_uuid,      null: false
      t.uuid :exercise_uuid,   null: false
      t.boolean :is_spe,       null: false
      t.boolean :is_pe,        null: false

      t.timestamps             null: false
    end

    add_index :assigned_exercises, [:exercise_uuid, :assignment_uuid], unique: true
    add_index :assigned_exercises, [:trial_uuid, :assignment_uuid], unique: true
  end
end
