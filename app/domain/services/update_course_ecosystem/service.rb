class Services::UpdateCourseEcosystem::Service
  def process(update_requests:)
    update_responses = update_requests.map do |request|
      preparation = EcosystemPreparation.find_by(uuid: request[:preparation_uuid])

      if preparation.nil?
        status = 'preparation_unknown'
      else
        course = preparation.course

        if course&.ecosystem_preparations&.order(:sequence_number)&.last != preparation
          status = 'preparation_obsolete'
        elsif preparation.ecosystem_update.present?
          # TODO: Check some other record here when we support whatever processing needs to happen
          status = 'updated_and_ready'
        else
          update = EcosystemUpdate.new(
            uuid: request[:request_uuid],
            ecosystem_preparation: preparation
          )
          EcosystemUpdate.import [update], on_duplicate_key_ignore: true

          status = 'updated_but_unready'
        end
      end

      { request_uuid: request[:request_uuid], update_status: status }
    end

    { update_responses: update_responses }
  end
end
