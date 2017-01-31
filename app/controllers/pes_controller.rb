class PesController < JsonApiController

  def fetch
    with_json_apis(input_schema:  _fetch_request_payload_schema,
                   output_schema: _fetch_response_payload_schema) do
      request_payload = json_parsed_request_payload
      pe_requests = request_payload.deep_symbolize_keys.fetch(:pe_requests)

      service = Services::FetchAssignmentPes::Service.new
      result = service.process(pe_requests: pe_requests)

      pe_responses = result.fetch(:pe_responses).map do |response|
        response.slice(:assignment_uuid, :exercise_uuids, :assignment_status)
      end

      render json: { pe_responses: pe_responses }.to_json, status: 200
    end
  end

  protected

  def _fetch_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'pe_requests': {
          'type': 'array',
          'items': {'$ref': '#definitions/pe_request'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['pe_requests'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'pe_request': {
          'type': 'object',
          'properties': {
            'assignment_uuid': {'$ref': '#standard_definitions/uuid'},
            'max_num_exercises': {
              'type': 'integer',
              'minimum': 0,
              'maximum': 100,
            },
          },
          'required': ['assignment_uuid', 'max_num_exercises'],
          'additionalProperties': false,
        },
      },
    }
  end


  def _fetch_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'pe_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/pe_response'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['pe_responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'pe_response': {
          'type': 'object',
          'properties': {
            'assignment_uuid': {'$ref': '#standard_definitions/uuid'},
            'exercise_uuids': {
              'type': 'array',
              'items': {'$ref': '#standard_definitions/uuid'},
              'minItems': 0,
              'maxItems': 100,
            },
            'assignment_status': {
              'type': 'string',
              'enum': ['assignment_unknown', 'assignment_unready', 'assignment_ready'],
            },
          },
          'required': ['assignment_uuid', 'exercise_uuids', 'assignment_status'],
          'additionalProperties': false,
        },
      },
    }
  end

end
