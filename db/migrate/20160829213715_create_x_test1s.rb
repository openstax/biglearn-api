class CreateXTest1s < ActiveRecord::Migration
  def change
    create_table :x_test1s do |t|
      t.uuid  :uuid,  null: false

      t.timestamps    null: false
    end

    add_index  :x_test1s,  :uuid,
                            unique: true

    add_index  :x_test1s,  :created_at
  end
end
