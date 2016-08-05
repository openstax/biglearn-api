class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.string  :uuid,   null: false,  limit: 36
      t.string  :value,  null: false,  limit: 50

      t.timestamps       null: false
    end

    add_index :records,  :uuid,
                         unique: true
  end
end
