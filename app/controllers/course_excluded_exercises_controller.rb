class CourseExcludedExercisesController < ExcludedExercisesController

  def update
    with_json_apis(input_schema:  _update_request_payload_schema,
                   output_schema: _update_response_payload_schema) do
      request_payload = json_parsed_request_payload

      course_uuid = request_payload.fetch('course_uuid')
      exclusions = request_payload.fetch('exclusions')
      sequence_number = request_payload.fetch('sequence_number')

      service = Services::UpdateGloballyExcludedExercises::Service.new
      result = service.process(
        course_uuid: course_uuid,
        sequence_number: sequence_number,
        exclusions: exclusions,
      )

      response_payload = { status: 'success' }

      render json: response_payload.to_json, status: 200
    end
  end


  def _update_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'request_uuid':    {'$ref': '#/standard_definitions/uuid'},
        'course_uuid':     {'$ref': '#/standard_definitions/uuid'},
        'sequence_number': {'$ref': '#/standard_definitions/non_negative_integer'},
        'exclusions': {
          'type': 'array',
          'items': {'$ref': '#/definitions/exclusion'},
          'minItems': 0,
          'maxItems': 10000,
        },
      },
      'required': ['request_uuid', 'course_uuid', 'sequence_number', 'exclusions'],
      'additionalProperties': false,

      'definitions': _definitions,
      'standard_definitions': _standard_definitions,
    }
  end


  def _update_response_payload_schema
    _response
  end

end
