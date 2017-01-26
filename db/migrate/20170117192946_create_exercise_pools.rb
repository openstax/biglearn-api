class CreateExercisePools < ActiveRecord::Migration
  def change
    create_table :exercise_pools do |t|
      t.uuid    :uuid,                                      null: false, index: { unique: true }
      t.uuid    :container_uuid,                            null: false, index: true,
                                                            foreign_key: {
                                                              to_table: :book_containers,
                                                              to_column: :uuid
                                                            }
      t.boolean :use_for_clue,                              null: false
      t.string  :use_for_personalized_for_assignment_types, null: false, array: true
      t.uuid    :exercise_uuids,                            null: false, array: true

      t.timestamps                                          null: false
    end
  end
end
