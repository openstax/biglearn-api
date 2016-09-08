class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.uuid      :uuid,             null: false
      t.uuid      :trial_uuid,       null: false
      t.integer   :trial_sequence,   null: false
      t.uuid      :learner_uuid,     null: false
      t.uuid      :question_uuid,    null: false
      t.boolean   :is_correct,       null: false
      t.datetime  :responded_at,     null: false

      t.timestamps
    end

    add_index  :responses,  :uuid,
                            unique: true

    add_index  :responses,  [:trial_uuid, :trial_sequence],
                            unique: true

    add_index  :responses,  :created_at
  end
end
