class ResponsesController < JsonApiController

  def record
    with_json_apis(input_schema:  _record_request_payload_schema,
                   output_schema: _record_response_payload_schema) do
      request_payload = json_parsed_request_payload
      response_data = request_payload.fetch('responses').map(&:deep_symbolize_keys)

      service = Services::ExternalApi::RecordResponses.new
      recorded_response_uuids = service.process(response_data: response_data)

      render json: {'recorded_response_uuids': recorded_response_uuids}.to_json, status: 200
    end
  end


  def _record_request_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/response'},
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
            'response_uuid':  {'$ref': '#standard_definitions/uuid'},
            'trial_uuid':     {'$ref': '#standard_definitions/uuid'},
            'trial_sequence': {'$ref': '#standard_definitions/non_negative_integer'},
            'learner_uuid':   {'$ref': '#standard_definitions/uuid'},
            'question_uuid':  {'$ref': '#standard_definitions/uuid'},
            'is_correct':     {'type': 'boolean'},
            'responded_at':   {'$ref': '#standard_definitions/datetime'},
          },
          'required': [
            'response_uuid',
            'trial_uuid',
            'trial_sequence',
            'learner_uuid',
            'question_uuid',
            'is_correct',
            'responded_at',
          ],
          'additionalProperties': false,
        },
      },
    }
  end


  def _record_response_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'recorded_response_uuids': {
          'type': 'array',
          'items': {'$ref': '#standard_definitions/uuid'},
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
