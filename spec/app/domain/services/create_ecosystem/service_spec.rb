require 'rails_helper'

RSpec.describe Services::CreateEcosystem::Service, type: :service do
  let(:service)              { described_class.new }

  let(:given_ecosystem_uuid) { SecureRandom.uuid }

  let(:given_exercises)      do
    6.times.map do
      {
        uuid: SecureRandom.uuid,
        exercises_uuid: SecureRandom.uuid,
        exercises_version: rand(10),
        los: 5.times.map{ SecureRandom.uuid }
      }
    end
  end

  let(:given_book_pages)     do
    assignment_types = ['homework', 'reading', 'concept-coach']

    4.times.map do
      {
        container_uuid: SecureRandom.uuid,
        container_parent_uuid: given_book_chapters.sample[:container_uuid],
        container_cnx_identity: "#{SecureRandom.uuid}@#{rand(10)}.#{rand(10)}",
        pools: 3.times.map do
          {
            use_for_clue: [true, false].sample,
            use_for_personalized_for_assignment_types: assignment_types.sample(2),
            exercise_uuids: given_exercises.sample(3).map{ |exercise_hash| exercise_hash[:uuid] }
          }
        end
      }
    end
  end
  let(:given_book_chapters)  do
    2.times.map do
      {
        container_uuid: SecureRandom.uuid,
        container_parent_uuid: nil,
        container_cnx_identity: "#{SecureRandom.uuid}@#{rand(10)}.#{rand(10)}",
        pools: [
          {
            use_for_clue: true,
            use_for_personalized_for_assignment_types: [],
            exercise_uuids: given_exercises.sample(4).map{ |exercise_hash| exercise_hash[:uuid] }
          }
        ]
      }
    end
  end
  let(:given_book_contents)  { given_book_chapters + given_book_pages }

  let(:given_book)           do
    {
      cnx_identity: "#{SecureRandom.uuid}@#{rand(10)}.#{rand(10)}",
      contents: given_book_contents
    }
  end

  let(:action) do
    service.process(ecosystem_uuid: given_ecosystem_uuid,
                    book: given_book,
                    exercises: given_exercises)
  end

  context "when a previously-existing ecosystem_uuid is given" do
    before(:each) do
      FactoryGirl.create(:ecosystem_event, uuid: given_ecosystem_uuid, type: :create_ecosystem)
    end

    it "an EcosystemEvent is NOT created" do
      expect{action}.not_to change{EcosystemEvent.count}
    end

    it "the ecosystem_uuid is returned" do
      expect(action.fetch(:created_ecosystem_uuid)).to eq(given_ecosystem_uuid)
    end
  end

  context "when a previously non-existing ecosystem_uuid is given" do
    it "an EcosystemEvent is created, as well as associated records with the correct attributes" do
      given_exercise_pools = given_book_contents.flat_map{|container_hash| container_hash[:pools]}

      expect{action}.to change{EcosystemEvent.count}.by(1)
                    .and change{BookContainer.count}.by(given_book_contents.size)

      ecosystem = EcosystemEvent.find_by(uuid: given_ecosystem_uuid)
      book = ecosystem.data.deep_symbolize_keys[:book]
      contents = book[:contents]
      expect(contents.length).to eq given_book_contents.size
      pools = contents.flat_map{ |content| content[:pools] }
      expect(pools.length).to eq given_exercise_pools.size
      valid_exercise_uuids = given_exercises.map{ |ex_hash| ex_hash[:uuid] }
      uniq_exercise_uuids = pools.flat_map{ |pool| pool[:exercise_uuids] }.uniq
      uniq_exercise_uuids.each do |exercise_uuid|
        expect(valid_exercise_uuids).to include(exercise_uuid)
      end

      given_book_contents.each do |content|
        expect(BookContainer.exists?(uuid: content[:container_uuid])).to eq true
      end
    end

    it "the ecosystem_uuid is returned" do
      expect(action.fetch(:created_ecosystem_uuid)).to eq(given_ecosystem_uuid)
    end
  end
end
