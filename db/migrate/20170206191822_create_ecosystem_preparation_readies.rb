class CreateEcosystemPreparationReadies < ActiveRecord::Migration[4.2]
  def change
    create_table :ecosystem_preparation_readies do |t|
      t.uuid :uuid, null: false, index: { unique: true }

      t.timestamps  null: false
    end
  end
end
