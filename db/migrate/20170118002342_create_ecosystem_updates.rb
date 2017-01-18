class CreateEcosystemUpdates < ActiveRecord::Migration
  def change
    create_table :ecosystem_updates do |t|
      t.uuid :uuid,             null: false, index: { unique: true }
      t.uuid :preparation_uuid, null: false, index: { unique: true }

      t.timestamps              null: false
    end
  end
end
