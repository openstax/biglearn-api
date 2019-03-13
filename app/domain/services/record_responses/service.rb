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
        sequence_number_association_extra_attributes: {
            initial_ecosystem_uuid: response.fetch(:ecosystem_uuid),
        },
        data: response.slice(
          :response_uuid,
          :course_uuid,
          :sequence_number,
          :ecosystem_uuid,
          :trial_uuid,
          :student_uuid,
          :exercise_uuid,
          :is_correct,
          :is_real_response,
          :responded_at
        )
      }

      response.fetch(:response_uuid)
    end

    CourseEvent.append course_event_attributes

    { recorded_response_uuids: recorded_response_uuids }
  end
end
