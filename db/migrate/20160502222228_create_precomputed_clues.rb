class CreatePrecomputedClues < ActiveRecord::Migration
  def change
    create_table :precomputed_clues do |t|
      t.string      :uuid,            null: false,  limit: 36
      t.references  :learner_pool,    null: false,  foreign_key: true
      t.references  :question_pool,   null: false,  foreign_key: true
      t.references  :clue,            null: false,  foreign_key: true
      t.timestamps                    null: false

      t.index :learner_pool_id
      t.index :question_pool_id
      t.index :clue_id,  unique: true
    end
  end
end
