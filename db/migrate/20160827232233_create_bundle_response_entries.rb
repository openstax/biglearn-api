class CreateBundleResponseEntries < ActiveRecord::Migration
  def change
    create_table :bundle_response_entries do |t|
      t.uuid  :uuid,         null: false
      t.uuid  :bundle_uuid,  null: false

      t.timestamps           null: false
    end

    add_index :bundle_response_entries, :uuid,
                                        unique: true,
                                        name: 'index_bre_uuid_unique'

    add_index :bundle_response_entries, :bundle_uuid,
                                        name: 'index_bre_b_uuid'
  end
end
