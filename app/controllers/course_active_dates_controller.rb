class CourseActiveDatesController < JsonApiController

  def update
    with_json_apis(input_schema:  _update_request_payload_schema,
                   output_schema: _update_response_payload_schema) do
      request_payload = json_parsed_request_payload

      request_uuid = request_payload.fetch(:request_uuid)
      course_uuid = request_payload.fetch(:course_uuid)
      sequence_number = request_payload.fetch(:sequence_number)
      starts_at = request_payload.fetch(:starts_at)
      ends_at = request_payload.fetch(:ends_at)

      service = Services::UpdateCourseActiveDates::Service.new
      result = service.process(
        request_uuid: request_uuid,
        course_uuid: course_uuid,
        sequence_number: sequence_number,
        starts_at: starts_at,
        ends_at: ends_at
      )

      response_payload = { updated_course_uuid: result.fetch(:updated_course_uuid) }

      render json: response_payload.to_json, status: 200
    end
  end


  def _update_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'request_uuid':    {'$ref': '#standard_definitions/uuid'},
        'course_uuid':     {'$ref': '#/standard_definitions/uuid'},
        'sequence_number': {'$ref': '#/standard_definitions/non_negative_integer'},
        'starts_at':       {'$ref': '#/standard_definitions/datetime'},
        'ends_at':         {'$ref': '#/standard_definitions/datetime'}
      },
      'required': ['course_uuid', 'starts_at', 'ends_at'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions
    }
  end


  def _update_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'updated_course_uuid': {'$ref': '#/standard_definitions/uuid'},
      },
      'required': ['updated_course_uuid'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions
    }
  end

end
