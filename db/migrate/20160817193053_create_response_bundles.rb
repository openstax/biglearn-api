class CreateResponseBundles < ActiveRecord::Migration
  def change
    create_table :response_bundles do |t|
      t.uuid     :response_bundle_uuid,  null: false
      t.boolean  :is_open,               null: false

      t.timestamps                       null: false
    end

    add_index  :response_bundles,  :response_bundle_uuid,
                                   unique: true

    add_index  :response_bundles,  :is_open
  end
end
