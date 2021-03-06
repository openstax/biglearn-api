class CreateEcosystemEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :ecosystem_events do |t|
      t.uuid    :uuid,            null: false, index: { unique: true }
      t.uuid    :ecosystem_uuid,  null: false
      t.integer :sequence_number, null: false
      t.integer :type,            null: false
      t.jsonb   :data,            null: false

      t.timestamps                null: false
    end

    add_index :ecosystem_events, [:ecosystem_uuid, :sequence_number], unique: true
    add_index :ecosystem_events, [:ecosystem_uuid, :type]
  end
end
