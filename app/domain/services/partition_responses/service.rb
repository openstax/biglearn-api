class Services::PartitionResponses::Service
  def initialize
    @bundle_manager = Openstax::BundleManager::Manager.new(model: Response)
  end

  def process(max_responses_to_process:)
    Response.transaction(isolation: :repeatable_read) do
      bundle_manager.partition(max_records_to_process: max_responses_to_process)
    end
    self
  end

  protected

  attr_reader :bundle_manager
end