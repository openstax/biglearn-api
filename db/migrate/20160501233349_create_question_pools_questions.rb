class CreateQuestionPoolsQuestions < ActiveRecord::Migration
  def change
    create_table :question_pools_questions, id: false do |t|
      t.belongs_to :question,       null: false, index: true
      t.belongs_to :question_pool,  null: false, index: true
    end
  end
end
