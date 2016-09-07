require 'rails_helper'

RSpec.describe Services::BundleResponses::Service do
  let(:service) { Services::BundleResponses::Service.new }

  let(:action) {
    service.process(
      max_responses_to_process: given_max_responses_to_process,
      max_responses_per_bundle: given_max_responses_per_bundle,
      max_age_per_bundle:       given_max_age_per_bundle,
      partition_count:          given_partition_count,
      partition_modulo:         given_partition_modulo,
    )
  }

  let(:given_max_responses_to_process) { 10 }
  let(:given_max_responses_per_bundle) { 5 }
  let(:given_max_age_per_bundle)       { 2.seconds }
  let(:given_partition_count)          { 7 }
  let(:given_partition_modulo)         { 1 }

  let(:bundle_manager) {
    dbl = object_double(Openstax::BundleManager::Manager.new(model: Response))
    allow(dbl).to receive(:bundle)
              .with(
                max_records_to_process: given_max_responses_to_process,
                max_records_per_bundle: given_max_responses_per_bundle,
                max_age_per_bundle:     given_max_age_per_bundle,
                partition_count:        given_partition_count,
                partition_modulo:       given_partition_modulo,
              )
    dbl
  }

  before(:each) do
    allow(Openstax::BundleManager::Manager).to receive(:new)
                                           .with(model: Response)
                                           .and_return(bundle_manager)
  end

  it "it delegates to its BundleManager with the correct parameters" do
    action
    expect(bundle_manager).to have_received(:bundle)
  end
end
