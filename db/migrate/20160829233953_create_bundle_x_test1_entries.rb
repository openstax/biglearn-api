class CreateBundleXTest1Entries < ActiveRecord::Migration
  def change
    create_table :bundle_x_test1_entries do |t|
      t.uuid  :uuid,         null: false
      t.uuid  :bundle_uuid,  null: false

      t.timestamps           null: false
    end

    add_index :bundle_x_test1_entries,  :uuid,
                                        unique: true,
                                        name: 'index_bxt1e_uuid_uniq'

    add_index :bundle_x_test1_entries,  :bundle_uuid
  end
end
