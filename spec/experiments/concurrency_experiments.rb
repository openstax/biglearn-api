require 'rails_helper'

class ExperIncreasingCounter < ActiveRecord::Base
end

RSpec.describe 'concurrency experiments' do
  context 'monotonically increasing counter' do
    it 'works as expected' do
      expect(ExperIncreasingCounter.count).to eq(0)

      ActiveRecord::Base.clear_active_connections!

      num_threads  =  2
      num_trials   =  100
      num_entities =  10000

      entity_uuids = num_entities.times.map{ SecureRandom.uuid.to_s }

      num_trials.times do |trial_idx|
        wait_for_it = true
        threads = num_threads.times.map do |thread_idx|
          Thread.new do
            entity_uuid = entity_uuids[rand(entity_uuids.size)]

            loop do
              break unless wait_for_it
            end

            start_time ||= Time.now

            begin
              ActiveRecord::Base.connection_pool.with_connection do
                ExperIncreasingCounter.transaction(isolation: :serializable) do
                  if true
                    ExperIncreasingCounter.connection.execute(
                      "INSERT INTO exper_increasing_counters (uuid, counter) VALUES (" +
                      "  '#{entity_uuid}', " +
                      "  (SELECT COALESCE(MAX(counter),0) " +
                      "   FROM exper_increasing_counters " +
                      "   WHERE uuid = '#{entity_uuid}') " +
                      "  + 1 " +
                      ") "
                    )
                  else
                    nonce = ExperIncreasingCounter.where{uuid == entity_uuid}.count + 1
                    record = ExperIncreasingCounter.create!(
                      uuid:    entity_uuid,
                      counter: nonce,
                    )
                  end
                end
              end
            rescue ActiveRecord::StatementInvalid => ex
              retry if Time.now < start_time + 5.seconds
              raise ex
            end
          end
        end

        wait_for_it = false
        threads.map(&:join)
      end

      records = ActiveRecord::Base.connection_pool.with_connection do
        ExperIncreasingCounter.transaction(isolation: :serializable) do
          ExperIncreasingCounter.find_each.to_a
        end
      end

      records.group_by{|rec| rec.uuid}
              .each{ |(key, values)|
                count    = values.count
                counters = values.map(&:counter)
                expect(counters.sort).to eq( (1..count).to_a.sort )
              }
    end
  end
end
