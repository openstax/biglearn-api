class CreateBooks < ActiveRecord::Migration
  def change
    enable_extension 'citext'

    create_table :books do |t|
      t.uuid   :uuid,           null: false, index: { unique: true }
      t.citext :cnx_identity,   null: false, index: { unique: true }

      t.timestamps              null: false
    end
  end
end
