class Services::UpdateCourseEcosystem::Service
  def process(update_requests:)
    preparation_uuids = update_requests.map{ |request| request[:preparation_uuid] }
    preparations_by_uuid = CourseEvent.ecosystem_preparation.where(uuid: preparation_uuids)
                                                            .index_by(&:uuid)
    ready_preparation_uuids_set = Set.new(
      EcosystemUpdateReady.where(preparation_uuid: preparation_uuids).pluck(:preparation_uuid)
    )

    course_event_attributes = []
    update_responses = update_requests.map do |request|
      preparation = preparations_by_uuid[request[:preparation_uuid]]

      if preparation.nil? || preparation.course_uuid != request[:course_uuid]
        status = 'preparation_unknown'
      # TODO: Some other check here that causes 'preparation_obsolete'?
      else
        course_event_attributes << {
          uuid: request[:request_uuid],
          type: :ecosystem_update,
          course_uuid: request[:course_uuid],
          sequence_number: request[:sequence_number],
          data: {
            request_uuid: request[:request_uuid],
            preparation_uuid: request[:preparation_uuid]
          }
        }

        is_ready = ready_preparation_uuids_set.include? request[:preparation_uuid]

        status = is_ready ? 'updated_and_ready' : 'updated_but_unready'
      end

      { request_uuid: request[:request_uuid], update_status: status }
    end

    CourseEvent.append course_event_attributes

    { update_responses: update_responses }
  end
end
