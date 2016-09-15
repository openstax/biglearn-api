class CreateBundleXTest1Bundles < ActiveRecord::Migration
  def change
    create_table :bundle_x_test1_bundles do |t|
      t.uuid     :uuid,             null: false
      t.integer  :partition_value,  null: false

      t.timestamps                  null: false
    end

    add_index :bundle_x_test1_bundles, :uuid,
                                       unique: true

    add_index :bundle_x_test1_bundles, :created_at
  end
end
