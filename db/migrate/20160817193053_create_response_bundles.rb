class CreateResponseBundles < ActiveRecord::Migration
  def change
    create_table :response_bundles do |t|
      t.uuid     :uuid,             null: false
      t.boolean  :is_open,          null: false

      t.integer  :partition_value,  null: false

      t.timestamps                  null: false
    end

    add_index  :response_bundles,  :uuid,
                                   unique: true

    add_index  :response_bundles,  :is_open
  end
end
