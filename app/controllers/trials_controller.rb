class TrialsController < JsonApiController
  def record_responses
    with_json_apis(input_schema:  _record_responses_request_payload_schema,
                   output_schema: _record_responses_response_payload_schema) do
      response_payload = { 'saved_response_uuids': [] }
      render json: response_payload.to_json, status: 200
    end
  end

  def _record_responses_request_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/response_def'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['responses'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,

      'definitions': {
        'response_def': {
          'type': 'object',
          'properties': {
            'trial_uuid':    {'$ref': '#standard_definitions/uuid'},
            'response_uuid': {'$ref': '#standard_definitions/uuid'},
            'learner_uuid':  {'$ref': '#standard_definitions/uuid'},
            'question_uuid': {'$ref': '#standard_definitions/uuid'},
            'is_correct': {
              'type': 'string',
              'enum': ['true', 'false'],
            },
          },
          'required': [
            'trial_uuid',
            'response_uuid',
            'learner_uuid',
            'question_uuid',
            'is_correct'
            ],
          'additionalProperties': false,
        },
      },

    }
  end

  def _record_responses_response_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',

      'standard_definitions': _standard_definitions,
    }
  end
end
