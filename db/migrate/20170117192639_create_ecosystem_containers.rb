class CreateEcosystemContainers < ActiveRecord::Migration
  def change
    create_table :ecosystem_containers do |t|
      t.uuid   :uuid,           null: false, index: { unique: true }
      t.uuid   :ecosystem_uuid, null: false, index: true
      t.uuid   :parent_uuid,                 index: true
      t.string :cnx_identity,                index: true

      t.timestamps              null: false
    end
  end
end
