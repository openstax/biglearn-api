FactoryGirl.define do
  factory :book_container do
    uuid         { SecureRandom.uuid }
    book
    cnx_identity { "#{SecureRandom.uuid}@#{rand(10)}.#{rand(10)}" }
  end
end
