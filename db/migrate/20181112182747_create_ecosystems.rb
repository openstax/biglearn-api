class CreateEcosystems < ActiveRecord::Migration[5.0]
  def change
    create_table :ecosystems do |t|
      t.uuid    :uuid,                     null: false, index: { unique: true }
      t.integer :metadata_sequence_number, null: false, index: { unique: true }

      t.timestamps                         null: false
    end

    reversible do |dir|
      dir.up do
        ecosystem_uuids = EcosystemEvent.create_ecosystem.order(:created_at).pluck(:ecosystem_uuid)
        ecosystem_uuids.each do |ecosystem_uuid|
          Ecosystem.new(uuid: ecosystem_uuid).set_metadata_sequence_number.save(validate: false)
        end
      end
    end
  end
end
