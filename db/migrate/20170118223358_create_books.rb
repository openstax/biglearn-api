class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.uuid   :uuid,           null: false, index: { unique: true }
      t.string :cnx_identity,                index: { unique: true }

      t.timestamps              null: false
    end
  end
end
