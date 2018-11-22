class CreateEcosystems < ActiveRecord::Migration[5.0]
  def change
    create_table :ecosystems do |t|
      t.uuid    :uuid,                     null: false, index: { unique: true }
      t.integer :metadata_sequence_number, null: false, index: { unique: true }
      t.integer :sequence_number,          null: false, index: true


      t.timestamps                         null: false
    end

    create_function :next_ecosystem_metadata_sequence_number

    reversible do |dir|
      dir.up do
        change_column_default :ecosystems, :metadata_sequence_number, -> do
          'next_ecosystem_metadata_sequence_number()'
        end

        Ecosystem.reset_column_information

        EcosystemEvent
          .group(:ecosystem_uuid)
          .order('MIN("created_at")')
          .pluck(:ecosystem_uuid, 'MAX("sequence_number")')
          .each do |ecosystem_uuid, sequence_number|
          Ecosystem.create!(uuid: ecosystem_uuid, sequence_number: sequence_number + 1)
        end
      end
    end
  end
end
