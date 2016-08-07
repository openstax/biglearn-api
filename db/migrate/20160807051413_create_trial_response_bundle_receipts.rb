class CreateTrialResponseBundleReceipts < ActiveRecord::Migration
  def change
    create_table :trial_response_bundle_receipts do |t|
      t.uuid    :trial_response_bundle_uuid,  null: false
      t.uuid    :receiver_uuid,               null: false
      t.boolean :is_confirmed,                null: false

      t.timestamps                            null: false
    end

    add_index  :trial_response_bundle_receipts,  :trial_response_bundle_uuid,
                                                 name: 'index_trbr_trb_uuid'

    add_index  :trial_response_bundle_receipts,  [:trial_response_bundle_uuid, :receiver_uuid],
                                                 unique: true,
                                                 name: 'index_trbr_r_uuid_scope_unique'
  end
end
