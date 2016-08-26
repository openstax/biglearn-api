require 'rails_helper'

RSpec.describe "background task: ResponseBundler" do
  let(:response_bundler) {
    BackgroundTasks::ResponseBundler.new(
      bundle_response_limit:  bundle_response_limit,
      bundle_age_limit:       bundle_age_limit,
      process_response_limit: process_response_limit,
      partition_count:        partition_count,
      partition_modulo:       target_partition_modulo)
  }

  let(:bundle_response_limit)  { 3  }
  let(:bundle_age_limit)       { 10.seconds }

  let(:process_response_limit) { 10 }

  let(:partition_count)            { 5 }
  let(:target_partition_modulo)    { 3 }
  let(:nontarget_partition_modulo) { 2 }

  let(:target_partition_value)    {
    begin
      value = rand(1000)
    end while value % partition_count != target_partition_modulo
    value
  }
  let(:nontarget_partition_value) { target_partition_value + 1 }

  let(:tpv) { target_partition_value }
  let(:npv) { nontarget_partition_value }

  context "when there are no Response records" do
    it "ResponseBundle records are NOT created" do
      expect{response_bundler.process}.to_not change{ResponseBundle.count}
    end
    it "ResponseBundle records are NOT updated" do
      split_time = Time.now
      expect(ResponseBundle.where{updated_at > split_time}).to be_empty
    end
    it "ResponseBundleEntry records are NOT created" do
      expect{response_bundler.process}.to_not change{ResponseBundleEntry.count}
    end
  end

  context "when there are no unbundled Response records in the target partition" do
    before(:each) do
      create(:response, partition_value: npv)
      create(:response, partition_value: npv)
    end

    it "ResponseBundle records are NOT created" do
      expect{response_bundler.process}.to_not change{ResponseBundle.count}
    end
    it "ResponseBundle records are NOT updated" do
      split_time = Time.now
      expect(ResponseBundle.where{updated_at > split_time}).to be_empty
    end
    it "ResponseBundleEntry records are NOT created" do
      expect{response_bundler.process}.to_not change{ResponseBundleEntry.count}
    end
  end

  context "when there are no open ResponseBundles in the target partition" do
    context "and the number of unbundled Response records in the target partition" do
      context "is below the count limit" do
        let(:bundle_response_limit) { 3 }

        before(:each) do
          create(:response, partition_value: npv)
          create(:response, partition_value: tpv)
          create(:response, partition_value: tpv)
          create(:response, partition_value: npv)
        end

        it "a new ResponseBundle record is created" do
          expect{response_bundler.process}.to change{ResponseBundle.count}.by(1)
        end

        it "the target Response records are added to the new ResponseBundle" do
          split_time = Time.now

          response_bundler.process

          target_responses      = Response.where{partition_value == my{target_partition_value}}
          new_response_bundle   = ResponseBundle.where{created_at > split_time}.first
          target_bundle_entries = ResponseBundleEntry.where{response_bundle_uuid == new_response_bundle.response_bundle_uuid}

          expect(target_responses.map(&:response_uuid)).to match_array(target_bundle_entries.map(&:response_uuid))
        end

        it "the new ResponseBundle remains open" do
          split_time = Time.now

          response_bundler.process

          new_response_bundles = ResponseBundle.where{created_at > split_time}

          aggregate_failures "new ResponseBundle checks" do
            expect(new_response_bundles.count).to eq(1)
            expect(new_response_bundles.select{|rb| !rb.is_open}).to be_empty
          end
        end
      end
      context "is equal to the count limit" do
        let(:bundle_response_limit) { 3 }

        before(:each) do
          create(:response, partition_value: npv)
          create(:response, partition_value: tpv)
          create(:response, partition_value: tpv)
          create(:response, partition_value: tpv)
          create(:response, partition_value: npv)
        end

        it "a new ResponseBundle record is created" do
          expect{response_bundler.process}.to change{ResponseBundle.count}.by(1)
        end
        it "the target Response records are added to the new ResponseBundle" do
          split_time = Time.now

          response_bundler.process

          target_responses      = Response.where{partition_value == my{target_partition_value}}
          new_response_bundles  = ResponseBundle.where{created_at > split_time}
          target_bundle_entries = ResponseBundleEntry.where{response_bundle_uuid.in new_response_bundles.map(&:response_bundle_uuid)}

          aggregate_failures "new ResponseBundle checks" do
            expect(new_response_bundles.count).to eq(1)
            expect(target_responses.map(&:response_uuid)).to match_array(target_bundle_entries.map(&:response_uuid))
          end
        end
        it "the new ResponseBundle is closed" do
          split_time = Time.now

          response_bundler.process

          new_response_bundles = ResponseBundle.where{created_at > split_time}
          aggregate_failures "new ResponseBundle checks" do
            expect(new_response_bundles.count).to eq(1)
            expect(new_response_bundles.select{|rb| rb.is_open}).to be_empty
          end
        end
      end
      context "is above the count limit" do
        let(:bundle_response_limit) { 2 }

        before(:each) do
          create(:response, partition_value: npv)
          create(:response, partition_value: tpv)
          create(:response, partition_value: tpv)
          create(:response, partition_value: tpv)
          create(:response, partition_value: tpv)
          create(:response, partition_value: tpv)
          create(:response, partition_value: npv)
        end

        it "multiple ResponseBundle records are created" do
          expect{response_bundler.process}.to change{ResponseBundle.count}.by(3)
        end
        it "the target Response records are added to the new ResponseBundles" do
          split_time = Time.now

          response_bundler.process

          target_responses      = Response.where{partition_value == my{target_partition_value}}
          new_response_bundles  = ResponseBundle.where{created_at > split_time}
          target_bundle_entries = ResponseBundleEntry.where{response_bundle_uuid.in new_response_bundles.map(&:response_bundle_uuid)}

          expect(target_responses.map(&:response_uuid)).to match_array(target_bundle_entries.map(&:response_uuid))
        end
        it "new ResponseBundles that are filled are closed" do
          split_time = Time.now

          response_bundler.process

          new_response_bundles = ResponseBundle.where{created_at > split_time}
          filled_response_bundles = new_response_bundles.select{|rb|
            bundle_response_limit <= ResponseBundleEntry.where{response_bundle_uuid == rb.response_bundle_uuid}
                                                        .count
          }

          aggregate_failures "new filled ResponseBundle checks" do
            expect(filled_response_bundles).to_not be_empty
            expect(filled_response_bundles.select{|rb| rb.is_open}).to be_empty
          end
        end
        it "the new ResponseBundle that is unfilled remains open" do
          split_time = Time.now

          response_bundler.process

          new_response_bundles = ResponseBundle.where{created_at > split_time}
          unfilled_response_bundles = new_response_bundles.select{|rb|
            bundle_response_limit > ResponseBundleEntry.where{response_bundle_uuid == rb.response_bundle_uuid}
                                                       .count
          }

          aggregate_failures "new unfilled ResponseBundle checks" do
            expect(unfilled_response_bundles.count).to eq(1)
            expect(unfilled_response_bundles.select{|rb| !rb.is_open}).to be_empty
          end
        end
      end
    end
  end

  context "when there are open ResponseBundles in the target partition" do
    let!(:pre_bundled_responses) { 5.times.map{ create(:response, partition_value: npv) } }

    let!(:pre_response_bundles) {
      [ create(:response_bundle, partition_value: npv, is_open: true),
        create(:response_bundle, partition_value: tpv, is_open: true),
        create(:response_bundle, partition_value: tpv, is_open: true),
        create(:response_bundle, partition_value: npv, is_open: true), ]
    }
    let(:target_bundles) { pre_response_bundles.values_at(1,2) }

    let!(:pre_response_bundle_entries) {
      response_index_map = [ [0,1], [2], [3], [4] ]

      pre_response_bundles.zip(response_index_map).map do |response_bundle, response_idxs|
        response_bundle_entries = response_idxs.map do |response_idx|
          create(:response_bundle_entry,
            response_bundle_uuid: response_bundle.response_bundle_uuid,
            response_uuid:        pre_bundled_responses.fetch(response_idx).response_uuid,
          )
        end
      end.flatten
    }

    context "and the number of unbundled Response records in the target partition" do

      context "is less than the number of available slots in the open ResponseBundles" do
        let(:bundle_response_limit) { 3 }

        let!(:pre_unbundled_responses) {
          [ create(:response, partition_value: npv),
            create(:response, partition_value: tpv),
            create(:response, partition_value: tpv),
            create(:response, partition_value: npv),
            create(:response, partition_value: tpv),
            create(:response, partition_value: npv), ]
        }
        let(:target_responses) { pre_unbundled_responses.values_at(1,2,4) }

        let!(:split_time) { time = Time.now; sleep(0.002); time }

        let(:target_bundle_entries) {
          ResponseBundleEntry.where{response_bundle_uuid.in my{target_bundles}.map(&:response_bundle_uuid)}
        }

        let(:new_target_bundle_entries) {
          target_bundle_entries.where{created_at > my{split_time}}
        }

        it "the target Response records are added to open target ResponseBundles" do
          response_bundler.process
          expect(new_target_bundle_entries.map(&:response_uuid)).to match_array(target_responses.map(&:response_uuid))
        end
        it "unfilled target ResponseBundles remain open" do
          response_bundler.process

          unfilled_bundles = target_bundles.select{ |bundle|
            num_bundle_entries = target_bundle_entries.select{ |entry|
              entry.response_bundle_uuid == bundle.response_bundle_uuid
            }.count
            num_bundle_entries < bundle_response_limit
          }

          aggregate_failures "checks" do
            expect(unfilled_bundles).to_not be_empty
            expect(unfilled_bundles.select{|bundle| !bundle.reload.is_open}).to be_empty
          end
        end
        it "filled target ResponseBundles are closed" do
          response_bundler.process

          filled_bundles = target_bundles.select{ |bundle|
            num_bundle_entries = target_bundle_entries.select{ |entry|
              entry.response_bundle_uuid == bundle.response_bundle_uuid
            }.count
            num_bundle_entries >= bundle_response_limit
          }

          aggregate_failures "checks" do
            expect(filled_bundles).to_not be_empty
            expect(filled_bundles.select{|bundle| bundle.reload.is_open}).to be_empty
          end
        end
      end

      context "is equal to the number of available slots in the open ResponseBundle" do
        let(:bundle_response_limit) { 3 }

        let!(:pre_unbundled_responses) {
          [ create(:response, partition_value: npv),
            create(:response, partition_value: tpv),
            create(:response, partition_value: tpv),
            create(:response, partition_value: tpv),
            create(:response, partition_value: npv),
            create(:response, partition_value: tpv),
            create(:response, partition_value: npv), ]
        }
        let(:target_responses) { pre_unbundled_responses.values_at(1,2,3,5) }

        let!(:split_time) { time = Time.now; sleep(0.002); time }

        let(:target_bundle_entries) {
          ResponseBundleEntry.where{response_bundle_uuid.in my{target_bundles}.map(&:response_bundle_uuid)}
        }

        let(:new_target_bundle_entries) {
          target_bundle_entries.where{created_at > my{split_time}}
        }

        it "the target Response records are added to open target ResponseBundles" do
          response_bundler.process
          expect(new_target_bundle_entries.map(&:response_uuid)).to match_array(target_responses.map(&:response_uuid))
        end
        it "the target ResponseBundles are closed" do
          response_bundler.process

          aggregate_failures "checks" do
            expect(target_bundles).to_not be_empty
            expect(target_bundles.select{|bundle| bundle.reload.is_open}).to be_empty
          end
        end
      end

      context "is more than the number of available slots in the open ResponseBundles" do
        let(:bundle_response_limit) { 3 }

        let!(:pre_unbundled_responses) {
          [ create(:response, partition_value: npv),
            create(:response, partition_value: tpv),
            create(:response, partition_value: tpv),
            create(:response, partition_value: tpv),
            create(:response, partition_value: npv),
            create(:response, partition_value: tpv),
            create(:response, partition_value: tpv),
            create(:response, partition_value: tpv),
            create(:response, partition_value: tpv),
            create(:response, partition_value: tpv),
            create(:response, partition_value: npv), ]
        }
        let(:target_responses) { pre_unbundled_responses.values_at(1,2,3,5,6,7,8,9) }

        let!(:split_time) { time = Time.now; sleep(0.002); time }

        let(:target_bundle_entries) {
          ResponseBundleEntry.where{response_bundle_uuid.in my{target_bundles}.map(&:response_bundle_uuid)}
        }

        let(:new_target_bundle_entries) {
          target_bundle_entries.where{created_at > my{split_time}}
        }

        let(:created_bundles) {
          ResponseBundle.where{created_at > my{split_time}}
        }

        let(:updated_bundles) {
          target_bundles.to_a + created_bundles.to_a
        }

        let(:updated_bundle_entries) {
          ResponseBundleEntry.where{response_bundle_uuid.in my{updated_bundles}.map(&:response_bundle_uuid)}
        }

        it "target Response records are added to the open target ResponseBundles" do
          response_bundler.process
          expect(new_target_bundle_entries.map(&:response_bundle_uuid).uniq).to match_array(target_bundles.map(&:response_bundle_uuid))
        end
        it "the open target ResponseBundles are closed" do
          response_bundler.process
          aggregate_failures "checks" do
            expect(target_bundles).to_not be_empty
            expect(target_bundles.select{|bundle| bundle.reload.is_open}).to be_empty
          end
        end
        it "new ResponseBundles are created" do
          response_bundler.process
          expect(created_bundles).to_not be_empty
        end
        it "target Response records are added to the new ResponseBundles" do
          response_bundler.process
          target_entries = ResponseBundleEntry.where{response_bundle_uuid.in my{created_bundles}.map(&:response_bundle_uuid)}
          expect(target_entries.map(&:response_bundle_uuid).uniq).to match_array(created_bundles.map(&:response_bundle_uuid))
        end
        it "unfilled target ResponseBundles remain open" do
          response_bundler.process

          unfilled_bundles = updated_bundles.select{ |bundle|
            num_bundle_entries = updated_bundle_entries.select{ |entry|
              entry.response_bundle_uuid == bundle.response_bundle_uuid
            }.count
            num_bundle_entries < bundle_response_limit
          }

          aggregate_failures "checks" do
            expect(unfilled_bundles).to_not be_empty
            expect(unfilled_bundles.select{|bundle| !bundle.reload.is_open}).to be_empty
          end
        end
        it "filled target ResponseBundles are closed" do
          response_bundler.process

          filled_bundles = updated_bundles.select{ |bundle|
            num_bundle_entries = updated_bundle_entries.select{ |entry|
              entry.response_bundle_uuid == bundle.response_bundle_uuid
            }.count
            num_bundle_entries >= bundle_response_limit
          }

          aggregate_failures "checks" do
            expect(filled_bundles).to_not be_empty
            expect(filled_bundles.select{|bundle| bundle.reload.is_open}).to be_empty
          end
        end
      end

    end

  end

  context "when there open ResponseBundles in the target partition" do
    let(:process_time)               { Time.now }
    let(:old_bundle_creation_time)   { process_time - bundle_age_limit - 1.second }
    let(:young_bundle_creation_time) { process_time - bundle_age_limit + 1.second }

    let!(:old_target_bundle) {
      Timecop.freeze(old_bundle_creation_time) do
        create(:response_bundle, partition_value: tpv, is_open: true)
      end
    }
    let!(:old_nontarget_bundle) {
      Timecop.freeze(old_bundle_creation_time) do
        create(:response_bundle, partition_value: npv, is_open: true)
      end
    }

    let!(:young_target_bundle) {
      Timecop.freeze(young_bundle_creation_time) do
        create(:response_bundle, partition_value: tpv, is_open: true)
      end
    }

    let!(:young_nontarget_bundle) {
      Timecop.freeze(young_bundle_creation_time) do
        create(:response_bundle, partition_value: npv, is_open: true)
      end
    }

    it "old target ResponseBundles are closed" do
      response_bundler.process
      expect(old_target_bundle.reload.is_open).to eq(false)
    end
    it "old nontarget ResponseBundles are NOT closed" do
      response_bundler.process
      expect(old_nontarget_bundle.reload.is_open).to eq(true)
    end
    it "young target ResponseBundles are NOT closed" do
      response_bundler.process
      expect(young_target_bundle.reload.is_open).to eq(true)
    end
    it "young nontarget ResponseBundles are NOT closed" do
      response_bundler.process
      expect(young_nontarget_bundle.reload.is_open).to eq(true)
    end
  end
end
