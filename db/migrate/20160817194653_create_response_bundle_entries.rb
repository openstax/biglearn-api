class CreateResponseBundleEntries < ActiveRecord::Migration
  def change
    create_table :response_bundle_entries do |t|
      t.uuid  :response_bundle_uuid,  null: false
      t.uuid  :response_uuid,         null: false

      t.timestamps                    null: false
    end

    add_index  :response_bundle_entries,  [:response_bundle_uuid, :response_uuid],
                                          unique: true,
                                          name: 'index_rbe_rb_uuid_r_uuid_unique'

    add_index  :response_bundle_entries,  :response_bundle_uuid

    add_index  :response_bundle_entries,  :response_uuid
  end
end
