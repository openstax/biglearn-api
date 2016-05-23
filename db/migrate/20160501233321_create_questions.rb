class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string     :uuid,  null: false,  limit: 36
      t.timestamps         null: false
    end

    add_index :questions,  :uuid,
                           unique: true

    add_index :questions,  :created_at
  end
end
