class CreateBookContainers < ActiveRecord::Migration
  def change
    create_table :book_containers do |t|
      t.uuid :uuid, null: false, index: { unique: true }

      t.timestamps  null: false
    end
  end
end
