require 'rails_helper'

RSpec.describe Services::PartitionResponses::Service do
  let(:service) { Services::PartitionResponses::Service.new }

  let(:action) {
    service.process(max_responses_to_process: given_max_responses_to_process)
  }

  let(:given_max_responses_to_process) { 10 }

  let(:bundle_manager) {
    dbl = object_double(Openstax::BundleManager::Manager.new(model: Response))
    allow(dbl).to receive(:partition)
              .with(max_records_to_process: anything)
    dbl
  }

  before(:each) do
    allow(Openstax::BundleManager::Manager).to receive(:new)
                                           .with(model: Response)
                                           .and_return(bundle_manager)
  end

  it "it delegates to its BundleManager with the correct parameters" do
    action
    expect(bundle_manager).to have_received(:partition)
                          .with(max_records_to_process: given_max_responses_to_process)
  end
end
