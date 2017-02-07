class Services::RecordResponses::Service
  def process(responses:)
    course_event_attributes = []
    recorded_response_uuids = responses.uniq{ |response| response[:response_uuid] }
                                       .map do |response|
      course_event_attributes << {
        uuid: response[:response_uuid],
        type: :record_response,
        course_uuid: response[:course_uuid],
        sequence_number: response[:sequence_number],
        data: response.slice(
          :response_uuid,
          :trial_uuid,
          :student_uuid,
          :exercise_uuid,
          :is_correct,
          :responded_at
        )
      }

      response[:response_uuid]
    end

    CourseEvent.append course_event_attributes

    { recorded_response_uuids: recorded_response_uuids }
  end
end
