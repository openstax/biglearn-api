class CreateConcepts < ActiveRecord::Migration
  def change
    create_table :concepts do |t|
      t.string     :uuid,  null: false,  limit: 36
      t.timestamps         null: false
    end

    add_index :concepts,  :uuid,
                          unique: true

    add_index :concepts,  :created_at
  end
end
