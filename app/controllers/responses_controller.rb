class ResponsesController < JsonApiController

  def record
    respond_with_json_apis_and_service(
      input_schema:  _record_request_payload_schema,
      output_schema: _record_response_payload_schema,
      service: Services::RecordResponses::Service
    )
  end

  def _record_request_payload_schema
    {
      '$schema': JSON_SCHEMA,
      'type': 'object',
      'properties': {
        'responses': {
          'type': 'array',
          'items': {'$ref': '#/definitions/response'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'response': {
          'type': 'object',
          'properties': {
            'response_uuid':    {'$ref': '#/standard_definitions/uuid'},
            'course_uuid':      {'$ref': '#/standard_definitions/uuid'},
            'sequence_number':  {'$ref': '#/standard_definitions/non_negative_integer'},
            'ecosystem_uuid':   {'$ref': '#/standard_definitions/uuid'},
            'trial_uuid':       {'$ref': '#/standard_definitions/uuid'},
            'student_uuid':     {'$ref': '#/standard_definitions/uuid'},
            'exercise_uuid':    {'$ref': '#/standard_definitions/uuid'},
            'is_correct':       {'type': 'boolean'},
            'is_real_response': {'type': 'boolean'},
            'responded_at':     {'$ref': '#/standard_definitions/datetime'}
          },
          'required': [
            'response_uuid',
            'course_uuid',
            'sequence_number',
            'ecosystem_uuid',
            'trial_uuid',
            'student_uuid',
            'exercise_uuid',
            'is_correct',
            'is_real_response',
            'responded_at'
          ],
          'additionalProperties': false,
        },
      },
    }
  end

  def _record_response_payload_schema
    {
      '$schema': JSON_SCHEMA,
      'type': 'object',
      'properties': {
        'recorded_response_uuids': {
          'type': 'array',
          'items': {'$ref': '#/standard_definitions/uuid'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['recorded_response_uuids'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
    }
  end

end
