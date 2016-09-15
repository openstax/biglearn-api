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
  desc "Continuously run a sample task"
  task :sample => :environment do
    at_most_every(1.0.seconds) do
      puts 'sample task run'
    end
  end
end
