class FurtherImproveEventIndices < ActiveRecord::Migration[5.0]
  def change
    remove_index :course_events, [ :type, :course_uuid ]
    remove_index :ecosystem_events, [ :type, :ecosystem_uuid ]

    add_index :course_events, [ :type, :course_uuid, :sequence_number ],
              name: 'index_course_events_on_type_and_c_uuid_and_sequence_number', unique: true
    add_index :ecosystem_events, [ :type, :ecosystem_uuid, :sequence_number ],
              name: 'index_ecosystem_events_on_type_and_e_uuid_and_sequence_number', unique: true
  end
end
