class CreateResponseBundleConfirmations < ActiveRecord::Migration
  def change
    create_table :response_bundle_confirmations do |t|
      t.uuid  :response_bundle_uuid,  null: false
      t.uuid  :receiver_uuid,         null: false

      t.timestamps                    null: false
    end

    add_index  :response_bundle_confirmations,  :response_bundle_uuid

    add_index  :response_bundle_confirmations,  :receiver_uuid

    add_index  :response_bundle_confirmations,  [:response_bundle_uuid, :receiver_uuid],
                                                unique: true,
                                                name: 'index_rbc_rb_uuid_r_uuid_unique'
  end
end
