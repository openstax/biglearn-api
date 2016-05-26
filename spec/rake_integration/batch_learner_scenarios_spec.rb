require 'rails_helper'

shared_examples 'batching examples' do
  context 'with no unbatched Learners in the database' do
    it 'does not create any LearnerBatches' do
      learner_batches = LearnerBatch.create_new_batches(max_learners_per_batch: max_learners_per_batch)

      expect(learner_batches.count).to be(0)
    end
  end

  context 'with fewer than max_learners_per_batch unbatched Learners in the database' do
    let!(:target_num_unbatched_learners) { 7 }

    let!(:unbatched_learners) {
      create_unbatched_learners(count: target_num_unbatched_learners)
    }

    it 'creates one LearnerBatch having the appropriate entries' do
      learner_batches = LearnerBatch.create_new_batches(max_learners_per_batch: max_learners_per_batch)

      batched_learners_uuids = learner_batches.collect{ |learner_batch|
        LearnerBatchEntry.where{ learner_batch_uuid == learner_batch.uuid }
                         .collect(&:learner_uuid)
      }.flatten.uniq

      expect(learner_batches.count).to be(1)
      expect(learner_batches.collect(&:num_entries)).to eq([7])
      expect(batched_learners_uuids.sort).to eq(unbatched_learners.collect(&:uuid).sort)
    end
  end

  context 'with more than max_learners_per_batch unbatched Learners in the database' do
    let!(:target_num_unbatched_learners) { 25 }

    let!(:unbatched_learners) {
      create_unbatched_learners(count: target_num_unbatched_learners)
    }

    it 'creates multiple LearnerBatches, each having the appropriate entries' do
      learner_batches = LearnerBatch.create_new_batches(max_learners_per_batch: max_learners_per_batch)

      batched_learners_uuids = learner_batches.collect{ |learner_batch|
        LearnerBatchEntry.where{ learner_batch_uuid == learner_batch.uuid }
                         .collect(&:learner_uuid)
      }.flatten.uniq

      expect(learner_batches.count).to be(3)
      expect(learner_batches.collect(&:num_entries).sort).to eq([5, 10, 10])
      expect(batched_learners_uuids.sort).to eq(unbatched_learners.collect(&:uuid).sort)
    end
  end
end


describe 'batch:learner scenarios' do

  context 'with no batched Learners in the database' do
    let!(:max_learners_per_batch) { 10 }

    include_examples 'batching examples'
  end


  context 'with batched Learners in the database' do
    let!(:max_learners_per_batch) { 10 }

    let!(:target_num_batched_learners) { 25 }

    let!(:batched_learners) {
      create_batched_learners(
        max_learners_per_batch: max_learners_per_batch,
        num_batched_learners:   target_num_batched_learners
      )
    }

    include_examples 'batching examples'
  end

end


def create_batched_learners(max_learners_per_batch:, num_batched_learners:)
  batched_learner_uuids = target_num_batched_learners.times.collect{ SecureRandom.uuid.to_s }
  batched_learners = batched_learner_uuids.collect do |batched_learner_uuid|
    Learner.create!(uuid: batched_learner_uuid)
  end

  learner_batches = batched_learners.each_slice(max_learners_per_batch).collect do |batch_learners|
    learner_batch = LearnerBatch.create!(
      uuid:        SecureRandom.uuid.to_s,
      num_entries: batch_learners.count
    )

    batch_learner_entries = batch_learners.collect do |batch_learner|
      LearnerBatchEntry.create!(
        learner_batch_uuid: learner_batch.uuid,
        learner_uuid:       batch_learner.uuid
      )
    end

    learner_batch
  end

  batched_learners
end


def create_unbatched_learners(count:)
  unbatched_learner_uuids = count.times.collect{ SecureRandom.uuid.to_s }
  unbatched_learners = unbatched_learner_uuids.collect do |unbatched_learner_uuid|
    Learner.create!(uuid: unbatched_learner_uuid)
  end

  unbatched_learners
end
