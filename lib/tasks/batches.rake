def at_most_every(duration, &block)
  loop do
    t1 = Time.now
    block.call
    t2 = Time.now
    elapsed = t2 - t1
    sleep(duration - elapsed) if duration > elapsed
  end
end

namespace :batch do
  desc "Continuously create Learner Batches"
  task :learner => :environment do
    at_most_every(1.0.seconds) do
      LearnerBatch.create_new_batches
    end
  end

  desc "Continuously create Question-Concept Hint Batches"
  task :qch => :environment do
    at_most_every(1.5.seconds) do
      #QchBatch.create_new_batches
      puts 'creating QCH batches'
    end
  end
end
