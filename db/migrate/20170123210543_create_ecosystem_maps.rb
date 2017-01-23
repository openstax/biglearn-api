class CreateEcosystemMaps < ActiveRecord::Migration
  def change
    create_table :ecosystem_maps do |t|
      t.uuid :uuid,                     null: false, index: { unique: true }
      t.uuid :from_ecosystem_uuid,      null: false
      t.uuid :to_ecosystem_uuid,        null: false, index: true
      t.jsonb :cnx_pagemodule_mappings, null: false, array: true
      t.jsonb :exercise_mappings,       null: false, array: true

      t.timestamps                      null: false
    end

    add_index :ecosystem_maps, [:from_ecosystem_uuid, :to_ecosystem_uuid],
                               unique: true,
                               name: 'index_e_maps_from_e_uuid_to_e_uuid_uniq'
  end
end
