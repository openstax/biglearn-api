class Services::FetchResponseBundles::Service
  def initialize
    @bundle_manager = OpenStax::BundleManager::Manager.new(model: Response)
  end

  def process(max_bundles_to_return:,
              bundle_uuids_to_confirm:,
              receiver_uuid:,
              partition_count:,
              partition_modulo:)

    confirmed_bundle_uuids = Response.transaction(isolation: :serializable) do
      confirmed_bundle_uuids = bundle_manager.confirm(
        receiver_uuid:           receiver_uuid,
        bundle_uuids_to_confirm: bundle_uuids_to_confirm,
      )
      confirmed_bundle_uuids
    end

    fetched_data = Response.transaction(isolation: :serializable) do
      fetched_data = bundle_manager.fetch(
        max_bundles_to_return: max_bundles_to_return,
        receiver_uuid:         receiver_uuid,
        partition_count:       partition_count,
        partition_modulo:      partition_modulo,
      )
      fetched_data
    end

    responses = Response.where{uuid.in fetched_data.fetch(:model_uuids)}

    response_data = responses.map{ |response|
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

    results = {
      confirmed_bundle_uuids: confirmed_bundle_uuids,
      bundle_uuids:           fetched_data.fetch(:bundle_uuids),
      response_data:          response_data,
    }

    results
  end

  protected

  attr_reader :bundle_manager

end
