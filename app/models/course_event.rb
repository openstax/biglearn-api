class CourseEvent < ActiveRecord::Base
  include AppendOnly
  include HasUniqueUuid

  enum event_type: {
    create_course:                      0,
    prepare_course_ecosystem:           1,
    update_course_ecosystems:           2,
    update_rosters:                     3,
    update_course_active_dates:         4,
    update_globally_excluded_exercises: 5,
    update_course_excluded_exercises:   6,
    create_update_assignments:          7,
    record_responses:                   8
  }

  validates :event_type,      presence: true
  validates :course_uuid,     presence: true
  validates :sequence_number, presence: true,
                              uniqueness: { scope: :course_uuid },
                              numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def self.standard_import(attributes_array)
    events = attributes_array.map{ |attributes| new(attributes) }

    transaction(isolation: :serializable) do
      # We use validate: false here because the controller schemas and the DB
      # already enforce the presence/uniqueness/data type validations
      # ON CONFLICT DO NOTHING is used so we ignore duplicate inserts
      # We ignore duplicate imports (same uuid)
      # but explode if the sequence_number collides while the uuid is different
      import events, validate: false, on_duplicate_key_ignore: { conflict_target: [:uuid] }
    end
  end
end
