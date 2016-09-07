class Services::BundleResponses::Service
  def initialize
    @bundle_manager = Openstax::BundleManager::Manager.new(model: Response)
  end

  def process(max_responses_to_process:,
              max_responses_per_bundle:,
              max_age_per_bundle:,
              partition_count:,
              partition_modulo:)
    Response.transaction(isolation: :repeatable_read) do
      bundle_manager.bundle(
        max_records_to_process: max_responses_to_process,
        max_records_per_bundle: max_responses_per_bundle,
        max_age_per_bundle:     max_age_per_bundle,
        partition_count:        partition_count,
        partition_modulo:       partition_modulo,
      )
    end
    self
  end

  protected

  attr_reader :bundle_manager
end
