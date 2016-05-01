class CreateQuestionPools < ActiveRecord::Migration
  def change
    create_table :question_pools do |t|
      t.string     :uuid,  null: false,  limit: 36
      t.timestamps         null: false
    end

    add_index :question_pools, :uuid, unique: true
  end
end
