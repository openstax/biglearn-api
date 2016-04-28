class CreateLearners < ActiveRecord::Migration
  def change
    create_table :learners do |t|
      t.string     :uuid,  null: false,  limit: 36
      t.timestamps         null: false
    end

    add_index :learners, :uuid, unique: true
  end
end
