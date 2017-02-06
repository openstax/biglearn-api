class EcosystemEvent < ActiveRecord::Base
  include AppendOnlyWithUniqueUuid

  enum event_type: { create_ecosystem: 0 }

  validates :event_type,      presence: true
  validates :ecosystem_uuid,  presence: true
  validates :sequence_number, presence: true,
                              uniqueness: { scope: :ecosystem_uuid },
                              numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def self.append(attributes_array)
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
