class CreateClues < ActiveRecord::Migration
  def change
    create_table :clues do |t|
      t.string     :uuid,                  null: false,  limit: 36
      t.float      :aggregate,             null: false
      t.float      :left,                  null: false
      t.float      :right,                 null: false
      t.integer    :sample_size,           null: false
      t.integer    :unique_learner_count,  null: false
      t.integer    :confidence,            null: false
      t.integer    :level,                 null: false
      t.integer    :threshold,             null: false
      t.timestamps                         null: false

      t.index :uuid,  unique: true
    end
  end
end
