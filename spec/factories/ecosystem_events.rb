FactoryGirl.define do
  factory :ecosystem_event do
    uuid            { SecureRandom.uuid }
    ecosystem_uuid  { SecureRandom.uuid }
    sequence_number do
      (EcosystemEvent.where(ecosystem_uuid: ecosystem_uuid).maximum(:sequence_number) || -1) + 1
    end
    type            { EcosystemEvent.types.keys.sample }
    data            { {} }
  end
end
