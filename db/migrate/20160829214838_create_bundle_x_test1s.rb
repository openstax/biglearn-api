class CreateBundleXTest1s < ActiveRecord::Migration
  def change
    create_table :bundle_x_test1s do |t|
      t.uuid    :uuid,             null: false
      t.integer :partition_value,  null: false

      t.timestamps                 null: false
    end

    add_index :bundle_x_test1s,  :uuid,
                                 unique: true

    add_index :bundle_x_test1s,  :partition_value

    add_index :bundle_x_test1s,  :created_at
  end
end
