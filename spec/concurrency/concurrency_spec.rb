require 'rails_helper'

RSpec.describe 'concurrency' do
  it 'works' do
    expect(ActiveRecord::Base.connection.pool.size).to be >= 5

    num_threads =  4
    num_trials  = 10

    num_trials.times do |trial_idx|
      continue_to_block = true
      threads = num_threads.times.map do |thread_idx|
        Thread.new do
          trial_desc = "#{trial_idx}:#{thread_idx}"

          start_time = Time.now
          retries    = 0

          # puts "#{trial_desc} " + start_time.strftime('%H:%M:%S.%6N')

          values = 100000.times.map{
            {
              uuid:       rand(1_000_000).to_s,
              # uuid:       SecureRandom.uuid.to_s,
              value:      trial_desc,
              created_at: start_time.to_s,
              updated_at: start_time.to_s
            }
          }.sort_by{|h| h[:uuid]}

          value_string = values.map{ |value|
            "('#{value[:uuid]}','#{value[:value]}','#{value[:created_at]}','#{value[:updated_at]}')"
          }.join(",")

          ActiveRecord::Base.connection_pool.with_connection do
            begin
              # Record.transaction(isolation: :serializable) do
              Record.transaction do
                while continue_to_block
                  ## hold here to maximize concurrency
                end

                inserted_uuids = Record.connection.execute(
                  "INSERT INTO records (uuid, value, created_at, updated_at) " +
                  "VALUES #{value_string} " +
                  "ON CONFLICT DO NOTHING " +
                  "RETURNING uuid "
                ).collect{|hash| hash["uuid"]}

                duplicates = values.map{|v| v[:uuid]} - inserted_uuids
                # puts "#{trial_desc} dup count: #{duplicates.count}"
              end
            rescue StandardError
              retries += 1
              # puts "#{trial_desc}: retry (#{retries})"
              retry if Time.now - start_time < 1.0
              raise "#{trial_desc}: failure!"
            end

            # puts "#{trial_desc}: success (#{retries})"
          end
        end
      end
      continue_to_block = false
      threads.each(&:join)
    end
  end
end
                # Record.create!(uuid: SecureRandom.uuid.to_s, value: "#{trial_idx}:#{thread_idx}")
                # uuid         = SecureRandom.uuid.to_s
                # uuid         = (trial_idx + thread_idx) % 7
              #   uuid         = rand(10000)
              #   value        = "#{trial_idx}:#{thread_idx}"
              #   current_time = Time.now
              #   result = Record.connection.execute(
              #     "INSERT INTO records (uuid, value, created_at, updated_at) " +
              #     "VALUES ('#{uuid}', '#{value}', '#{current_time.to_s}', '#{current_time.to_s}') " +
              #     "ON CONFLICT DO NOTHING " +
              #     "RETURNING uuid "
              #   ).collect{|hash| hash["uuid"]}
              #   # puts "#{value}: #{result}"
              #   # Record.create!(uuid: thread_idx.to_s, value: "#{trial_idx}:#{thread_idx}")
              #   # ActiveRecord::Base.clear_active_connections!
              #   # sleep(1.0)
              # end
        #     end
        #   end
        # end
