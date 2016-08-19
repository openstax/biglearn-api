class CreateResponseBundleReceipts < ActiveRecord::Migration
  def change
    create_table :response_bundle_receipts do |t|
      t.uuid  :response_bundle_uuid,  null: false
      t.uuid  :receiver_uuid,         null: false

      t.timestamps                    null: false
    end

    add_index  :response_bundle_receipts,  :response_bundle_uuid

    add_index  :response_bundle_receipts,  :receiver_uuid

    add_index  :response_bundle_receipts,  [:response_bundle_uuid, :receiver_uuid],
                                           unique: true,
                                           name: 'index_rbr_rb_uuid_r_uuid_unique'
  end
end
