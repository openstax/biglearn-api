FactoryGirl.define do
  factory :ecosystem_preparation do
    uuid            { SecureRandom.uuid }
    course
    ecosystem
    sequence_number { (EcosystemPreparation.maximum(:sequence_number) || -1) + 1 }
  end
end
