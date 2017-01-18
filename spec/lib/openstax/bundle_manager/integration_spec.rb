require 'rails_helper'

RSpec.describe Openstax::BundleManager::Manager do
  3.times do
    it "works" do
      start_time = Time.now

      XTest1.count

      num_models = 2_000
      model_uuids = num_models.times.map{ SecureRandom.uuid }

      ActiveRecord::Base.clear_active_connections!

      wait_for_it = true

      model_creation_thread = Thread.new do
        ActiveRecord::Base.clear_active_connections!

        while wait_for_it do
          sleep 0.001
        end

        model_uuids.each_slice(72) do |uuids|
          ActiveRecord::Base.connection_pool.with_connection do
            ActiveRecord::Base.transaction(isolation: :repeatable_read) do
              # puts "record"
              models = uuids.map{|uuid| XTest1.new(uuid: uuid)}

              XTest1.import models, on_duplicate_key_ignore: true
            end
          end
          sleep(0.001)
        end
      end

      partition_thread = Thread.new do
        ActiveRecord::Base.clear_active_connections!

        manager = Openstax::BundleManager::Manager.new(model: XTest1)
        next_time = Time.now + (0.05).seconds

        while wait_for_it do
          sleep 0.001
        end

        loop do
          current_time = Time.now
          if current_time > next_time
            break if  (Bundle::XTest1.count == num_models)
            next_time = current_time + (0.05).seconds
          end
          fail "out of time!" if Time.now > start_time + 10.seconds

          ActiveRecord::Base.connection_pool.with_connection do
            ActiveRecord::Base.transaction(isolation: :repeatable_read) do
              # puts "partition"
              manager.partition(max_records_to_process: 100)
            end
          end
          sleep(0.001)
        end
      end

      bundle_modulos = [0,1]
      bundle_threads = bundle_modulos.map do |modulo|
        Thread.new do
          ActiveRecord::Base.clear_active_connections!

          manager = Openstax::BundleManager::Manager.new(model: XTest1)
          next_time = Time.now + (0.05).seconds

          while wait_for_it do
            sleep 0.001
          end

          loop do
            current_time = Time.now
            if current_time > next_time
              break if  (Bundle::XTest1Entry.count == num_models)
              next_time = current_time + (0.05).seconds
            end
            fail "out of time!" if Time.now > start_time + 10.seconds

            ActiveRecord::Base.connection_pool.with_connection do
              ActiveRecord::Base.transaction(isolation: :repeatable_read) do
                t1 = Time.now
                manager.bundle(
                  max_records_to_process: 200,
                  max_records_per_bundle: 50,
                  max_age_per_bundle:     (0.01).seconds,
                  partition_count:        bundle_modulos.count,
                  partition_modulo:       modulo,
                )
                # puts "bundle modulo: #{modulo} #{Time.now - t1}"
              end
            end
            sleep(0.001)
          end
        end
      end

      fetch_thread = Thread.new do
        ActiveRecord::Base.clear_active_connections!

        manager = Openstax::BundleManager::Manager.new(model: XTest1)

        receiver_uuid = SecureRandom.uuid

        unconfirmed_bundle_uuids = {}
        confirmed_bundle_uuids   = {}
        received_model_uuids     = {}

        loop do
          break if received_model_uuids.count == model_uuids.count
          fail "out of time!" if Time.now > start_time + 10.seconds

          ActiveRecord::Base.connection_pool.with_connection do
            ActiveRecord::Base.transaction(isolation: :repeatable_read) do
              # puts "confirm"
              bundle_uuids_to_confirm = unconfirmed_bundle_uuids.keys.take(20)
              bundle_uuids = manager.confirm(
                receiver_uuid:           receiver_uuid,
                bundle_uuids_to_confirm: bundle_uuids_to_confirm,
              )

              bundle_uuids.each do |uuid|
                unconfirmed_bundle_uuids.delete(uuid)
                confirmed_bundle_uuids[uuid] = true
              end
            end
          end

          ActiveRecord::Base.connection_pool.with_connection do
            ActiveRecord::Base.transaction(isolation: :repeatable_read) do
              # puts "fetch"
              fetch_modulos = [0,1,2]
              fetch_modulos.each do |modulo|
                results = manager.fetch(
                  goal_records_to_return: 100,
                  max_bundles_to_process: 10,
                  receiver_uuid:          receiver_uuid,
                  partition_count:        fetch_modulos.count,
                  partition_modulo:       modulo,
                )

                results.fetch(:model_uuids).each do |uuid|
                  received_model_uuids[uuid] = true
                end

                results.fetch(:bundle_uuids).each do |uuid|
                  unconfirmed_bundle_uuids[uuid] = true
                end
              end
            end
          end
          sleep(0.001)
        end
      end

      wait_for_it = false
      [model_creation_thread, partition_thread, bundle_threads, fetch_thread].flatten.each{|thread| thread.join}
    end
  end
end
