require 'rails_helper'

RSpec.describe "Response bundling", type: :acceptance do
  let!(:avoid_autoload_errors) {
    Response.count;
    Services::RecordResponses::Service.new
    Services::PartitionResponses::Service.new
    Services::BundleResponses::Service.new
    Services::FetchResponseBundles::Service.new
  }

  let(:num_given_responses)  { 2_000 }

  3.times do
    it "works" do
      start_time = Time.now

      ActiveRecord::Base.clear_active_connections!

      wait_for_it = true

      creation_thread = Thread.new do
        ActiveRecord::Base.clear_active_connections!

        service = Services::RecordResponses::Service.new

        while wait_for_it do
          sleep 0.001
        end

        num_given_responses.times.each_slice(10) do |values|
          response_data = values.map{ |value|
            response = build(:response)
            {
              response_uuid:  response.uuid,
              trial_uuid:     response.trial_uuid,
              trial_sequence: response.trial_sequence,
              learner_uuid:   response.learner_uuid,
              question_uuid:  response.question_uuid,
              is_correct:     response.is_correct,
              responded_at:   response.responded_at.utc.iso8601(6),
            }
          }
          ActiveRecord::Base.connection_pool.with_connection do
            service.process(response_data: response_data)
          end
          sleep(0.001)
        end
      end

      partition_thread = Thread.new do
        ActiveRecord::Base.clear_active_connections!

        service = Services::PartitionResponses::Service.new

        next_time = Time.now + (0.05).seconds

        while wait_for_it do
          sleep 0.001
        end

        loop do
          current_time = Time.now
          if current_time > next_time
            break if  (Bundle::Response.count == num_given_responses)
            next_time = current_time + (0.05).seconds
          end
          fail "out of time!" if Time.now > start_time + 10.seconds

          ActiveRecord::Base.connection_pool.with_connection do
            # puts "partition"
            service.process(max_responses_to_process: 100)
          end
          sleep(0.001)
        end
      end

      bundle_modulos = [0,1]
      bundle_threads = bundle_modulos.map do |modulo|
        Thread.new do
          ActiveRecord::Base.clear_active_connections!

          service = Services::BundleResponses::Service.new

          next_time = Time.now + (0.05).seconds

          while wait_for_it do
            sleep 0.001
          end

          loop do
            current_time = Time.now
            if current_time > next_time
              break if Bundle::ResponseEntry.count == num_given_responses
              next_time = current_time + (0.05).seconds
            end
            fail "out of time!" if Time.now > start_time + 10.seconds

            ActiveRecord::Base.connection_pool.with_connection do
              t1 = Time.now
              service.process(
                max_responses_to_process: 200,
                max_responses_per_bundle: 50,
                max_age_per_bundle:       (0.01).seconds,
                partition_count:          bundle_modulos.count,
                partition_modulo:         modulo,
              )
              # puts "bundle modulo: #{modulo} #{Time.now - t1}"
            end
            sleep(0.001)
          end
        end
      end

      fetch_thread = Thread.new do
        ActiveRecord::Base.clear_active_connections!

        service = Services::FetchResponseBundles::Service.new

        receiver_uuid = SecureRandom.uuid

        unconfirmed_bundle_uuids = {}
        confirmed_bundle_uuids   = {}
        received_response_uuids  = {}

        delays = {}

        loop do
          break if received_response_uuids.count == num_given_responses
          fail "out of time!" if Time.now > start_time + 10.seconds

          ActiveRecord::Base.connection_pool.with_connection do
            bundle_uuids_to_confirm = unconfirmed_bundle_uuids.keys.take(20)

            results = service.process(
              goal_max_responses_to_return: 1000,
              max_bundles_to_process:       100,
              bundle_uuids_to_confirm:      bundle_uuids_to_confirm,
              receiver_uuid:                receiver_uuid,
              partition_count:              1,
              partition_modulo:             0,
            )

            # puts "fetch (#{bundle_uuids_to_confirm.count} #{results.fetch(:confirmed_bundle_uuids).count} #{results.fetch(:bundle_uuids).count} #{results.fetch(:response_data).count})"

            results.fetch(:confirmed_bundle_uuids).each do |uuid|
              unconfirmed_bundle_uuids.delete(uuid)
              confirmed_bundle_uuids[uuid] = true
            end

            results.fetch(:response_data).each do |data|
              received_response_uuids[data.fetch(:response_uuid)] = true
              unless delays[data.fetch(:response_uuid)]
                delays[data.fetch(:response_uuid)] = Time.now - Time.parse(data.fetch(:responded_at))
              end
            end

            results.fetch(:bundle_uuids).each do |uuid|
              unconfirmed_bundle_uuids[uuid] = true
            end
          end
          sleep(0.001)
        end

        avg_delay = delays.inject(0.0){|result, (k,v)| result += v; result} / delays.count
        #puts "avg_delay = #{avg_delay}"

        min_delay = delays.sort_by{|(k,v)| v}.first.last
        #puts "min_delay = #{min_delay}"

        max_delay = delays.sort_by{|(k,v)| v}.last.last
        #puts "max_delay = #{max_delay}"
      end

      wait_for_it = false
      [creation_thread, partition_thread, bundle_threads, fetch_thread].flatten.each{|thread| thread.join}
    end
  end
end
