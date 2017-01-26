class CreateBookContainers < ActiveRecord::Migration
  def change
    create_table :book_containers do |t|
      t.uuid   :uuid,         null: false, index: { unique: true }
      t.uuid   :book_uuid,    null: false, index: true,
                              foreign_key: { to_table: :books, to_column: :uuid }
      t.uuid   :parent_uuid,               index: true,
                              foreign_key: { to_table: :book_containers, to_column: :uuid }
      t.string :cnx_identity,              index: true

      t.timestamps            null: false
    end
  end
end
