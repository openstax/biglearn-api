class CreateBundleResponseBundles < ActiveRecord::Migration
  def change
    create_table :bundle_response_bundles do |t|
      t.uuid    :uuid,             null: false
      t.integer :partition_value,  null: false

      t.timestamps                 null: false
    end

    add_index  :bundle_response_bundles,  :uuid,
                                          unique: true

    add_index  :bundle_response_bundles,  :partition_value

    add_index  :bundle_response_bundles,  :created_at
  end
end
