class CreateEcosystems < ActiveRecord::Migration
  def change
    create_table :ecosystems do |t|
      t.uuid :uuid,      null: false, index: { unique: true }
      t.uuid :book_uuid, null: false, index: true,
                         foreign_key: { to_table: :books, to_column: :uuid }

      t.timestamps       null: false
    end
  end
end
