class CreateBundleResponseConfirmations < ActiveRecord::Migration
  def change
    create_table :bundle_response_confirmations do |t|
      t.uuid  :bundle_uuid,    null: false
      t.uuid  :receiver_uuid,  null: false

      t.timestamps             null: false
    end

    add_index  :bundle_response_confirmations,  :receiver_uuid

    add_index  :bundle_response_confirmations,  :bundle_uuid,
                                                unique: true,
                                                name: 'index_brc_b_uuid_r_uuid_unique'
  end
end
