class ImproveEventIndices < ActiveRecord::Migration[5.0]
  def change
    remove_index :ecosystem_events, [:ecosystem_uuid, :type]
    remove_index :course_events,    [:course_uuid, :type]

    add_index :ecosystem_events, [:type, :ecosystem_uuid]
    add_index :course_events,    [:type, :course_uuid]
  end
end
