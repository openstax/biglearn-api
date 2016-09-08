class CreateBundleResponses < ActiveRecord::Migration
  def change
    create_table :bundle_responses do |t|
      t.uuid    :uuid,             null: false
      t.integer :partition_value,  null: false

      t.timestamps                 null: false
    end

    add_index  :bundle_responses,  :uuid,
                                   unique: true

    add_index  :bundle_responses,  :partition_value

    add_index  :bundle_responses,  :created_at
  end
end
