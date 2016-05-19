class CreateQuestionConceptHints < ActiveRecord::Migration
  def change
    create_table :question_concept_hints do |t|
      t.string     :uuid,      null: false,  limit: 36
      t.references :question,  null: false,  foreign_key: true
      t.references :concept,   null: false,  foreign_key: true
      t.timestamps             null: false

      t.index :uuid,                        unique: true
      t.index [:question_id, :concept_id],  unique: true
    end
  end
end
