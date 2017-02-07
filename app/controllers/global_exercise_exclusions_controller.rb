class GlobalExerciseExclusionsController < JsonApiController

  def update
    with_json_apis(input_schema:  _update_request_payload_schema,
                   output_schema: _update_response_payload_schema) do
      request_payload = json_parsed_request_payload

      request_uuid = request_payload.fetch(:request_uuid)
      course_uuid = request_payload.fetch(:course_uuid)
      sequence_number = request_payload.fetch(:sequence_number)
      exclusions = request_payload.fetch(:exclusions)

      service = Services::UpdateGlobalExerciseExclusions::Service.new
      result = service.process(
        request_uuid:    request_uuid,
        course_uuid:     course_uuid,
        sequence_number: sequence_number,
        exclusions:      exclusions
      )

      render json: { status: result[:status] }.to_json, status: 200
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
          'items': {'$ref': '#/standard_definitions/exercise_exclusion'},
          'minItems': 0,
          'maxItems': 10000,
        },
      },
      'required': ['request_uuid', 'sequence_number', 'exclusions'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions
    }
  end

  def _update_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'status': {
          'emum': ['success'],
        },
      },
      'required': ['status'],
      'additionalProperties': false,
    }
  end

end
