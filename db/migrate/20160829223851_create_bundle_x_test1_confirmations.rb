class CreateBundleXTest1Confirmations < ActiveRecord::Migration
  def change
    create_table :bundle_x_test1_confirmations do |t|
      t.uuid  :bundle_uuid,    null: false
      t.uuid  :receiver_uuid,  null: false

      t.timestamps             null: false
    end

    add_index  :bundle_x_test1_confirmations,  :bundle_uuid

    add_index  :bundle_x_test1_confirmations,  :receiver_uuid

    add_index  :bundle_x_test1_confirmations,  [:bundle_uuid, :receiver_uuid],
                                               unique: true,
                                               name: 'index_bxt1c_b_uuid_r_uuid_uniq'
  end
end
