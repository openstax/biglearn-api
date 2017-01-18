class CreateEcosystemPreparations < ActiveRecord::Migration
  def change
    create_table :ecosystem_preparations do |t|
      t.uuid :uuid,           null: false, index: { unique: true }
      t.uuid :course_uuid,    null: false, index: true
      t.uuid :ecosystem_uuid, null: false, index: true

      t.timestamps            null: false
    end
  end
end
