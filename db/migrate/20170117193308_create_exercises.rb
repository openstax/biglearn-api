class CreateExercises < ActiveRecord::Migration
  def change
    create_table :exercises do |t|
      t.uuid    :uuid,              null: false, index: { unique: true }
      t.uuid    :exercises_uuid,    null: false
      t.integer :exercises_version, null: false
      t.string  :los,               null: false, array: true

      t.timestamps                  null: false
    end

    add_index :exercises, [:exercises_uuid, :exercises_version],
                          unique: true
  end
end
