FactoryBot.define do
  factory :ecosystem_event do
    uuid            { SecureRandom.uuid }
    ecosystem
    sequence_number do
      (EcosystemEvent.where(ecosystem_uuid: ecosystem_uuid).maximum(:sequence_number) || -1) + 1
    end
    type            { EcosystemEvent.types.keys.sample }
    data            { {} }

    after(:build)   do |ecosystem_event|
      ecosystem_event.ecosystem ||= build(
        :ecosystem, uuid: ecosystem_event.ecosystem_uuid,
                    sequence_number: ecosystem_event.sequence_number + 1
      )
      ecosystem_event.ecosystem.sequence_number = [
        ecosystem_event.ecosystem.sequence_number, ecosystem_event.sequence_number + 1
      ].max
    end
  end
end
