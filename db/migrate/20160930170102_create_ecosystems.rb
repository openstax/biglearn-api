class CreateEcosystems < ActiveRecord::Migration
  def change
    create_table :ecosystems do |t|
      t.uuid        :uuid,        null: false

      t.timestamps                null: false
    end
    add_index       :ecosystems,  :uuid,
                                  unique: true
  end
end
