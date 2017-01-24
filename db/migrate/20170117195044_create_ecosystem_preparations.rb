class CreateEcosystemPreparations < ActiveRecord::Migration
  def change
    create_table :ecosystem_preparations do |t|
      t.uuid :uuid,               null: false, index: { unique: true }
      t.uuid :course_uuid,        null: false
      t.uuid :ecosystem_uuid,     null: false, index: true
      t.integer :sequence_number, null: false

      t.timestamps                null: false
    end

    add_index :ecosystem_preparations, [:course_uuid, :sequence_number], unique: true
  end
end
