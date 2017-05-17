class Services::RecordResponses::Service < Services::ApplicationService
  def process(responses:)
    course_event_attributes = []
    recorded_response_uuids = responses.uniq { |response| response.fetch(:response_uuid) }
                                       .map do |response|
      course_event_attributes << {
        uuid: response.fetch(:response_uuid),
        type: :record_response,
        course_uuid: response.fetch(:course_uuid),
        sequence_number: response.fetch(:sequence_number),
        data: response.slice(
          :response_uuid,
          :course_uuid,
          :sequence_number,
          :ecosystem_uuid,
          :trial_uuid,
          :student_uuid,
          :exercise_uuid,
          :is_correct,
          :responded_at
        )
      }

      response.fetch(:response_uuid)
    end

    CourseEvent.append course_event_attributes

    { recorded_response_uuids: recorded_response_uuids }
  end
end
