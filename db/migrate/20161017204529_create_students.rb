class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.uuid :uuid, null: false, index: { unique: true }

      t.timestamps  null: false
    end
  end
end
