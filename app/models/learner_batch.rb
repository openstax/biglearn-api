class LearnerBatch < ActiveRecord::Base
  def self.create_new_batches(max_learners_per_batch:)
    learner_batches = LearnerBatch.transaction(isolation: :serializable) do
      unbatched_learner_uuids = ActiveRecord::Base.connection.execute(
        'SELECT uuid FROM ' +
        'learners NATURAL LEFT JOIN learner_batch_entries ' +
        'WHERE learner_batch_uuid IS NULL '
      ).collect{|hash| hash["uuid"]}

      learner_batches = unbatched_learner_uuids.each_slice(max_learners_per_batch).collect do |batch_learner_uuids|
        learner_batch = LearnerBatch.create!(
          uuid:        SecureRandom.uuid.to_s,
          num_entries: batch_learner_uuids.count
        )

        batch_learner_entries = batch_learner_uuids.collect do |learner_uuid|
          LearnerBatchEntry.create!(
            learner_batch_uuid: learner_batch.uuid,
            learner_uuid:       learner_uuid
          )
        end

        learner_batch
      end

      learner_batches
    end

    learner_batches
  end
end
