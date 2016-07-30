class CreatePrecomputedClues < ActiveRecord::Migration
  def change
    create_table :precomputed_clues do |t|
      t.string      :uuid,                null: false,  limit: 36
      t.string      :learner_pool_uuid,   null: false,  limit: 36
      t.string      :question_pool_uuid,  null: false,  limit: 36
      t.string      :clue_uuid,           null: false,  limit: 36
      t.timestamps                        null: false
    end

    add_index :precomputed_clues,  :uuid,
                                   unique: true

    add_index :precomputed_clues,  :clue_uuid,
                                   unique: true

    add_index :precomputed_clues,  :learner_pool_uuid

    add_index :precomputed_clues,  :question_pool_uuid

    add_index :precomputed_clues,  :created_at
  end
end
