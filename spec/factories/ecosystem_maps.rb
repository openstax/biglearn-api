FactoryGirl.define do
  factory :ecosystem_map do
    uuid                    { SecureRandom.uuid }
    association             :from_ecosystem, factory: :ecosystem
    association             :to_ecosystem,   factory: :ecosystem
    cnx_pagemodule_mappings []
    exercise_mappings       []
  end
end
