class EcosystemEventsController < JsonApiController

  def fetch
    with_json_apis(input_schema:  _fetch_request_payload_schema,
                   output_schema: _fetch_response_payload_schema) do
      event_requests = json_parsed_request_payload.fetch(:ecosystem_event_requests)

      service = Services::FetchEcosystemEvents::Service.new
      response_payload = service.process(ecosystem_event_requests: event_requests)

      render json: response_payload.to_json, status: 200
    end
  end

  protected

  def _fetch_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'ecosystem_event_requests': {
          'type': 'array',
          'items': {'$ref': '#definitions/ecosystem_event_request'},
          'minItems': 0,
          'maxItems': 100
        }
      },
      'required': ['ecosystem_event_requests'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'ecosystem_event_request': {
          'type': 'object',
          'properties': {
            'request_uuid': {'$ref': '#standard_definitions/uuid'},
            'event_types': {
              'type': 'array',
              'items': {'$ref': '#standard_definitions/ecosystem_event_type'},
              'minItems': 1
            },
            'ecosystem_uuid':         {'$ref': '#standard_definitions/uuid'},
            'sequence_number_offset': {'$ref': '#standard_definitions/non_negative_integer'},
            'event_limit': {
              'type': 'integer',
              'minimum': 1,
              'maximum': 1000
            }
          },
          'required': ['ecosystem_uuid', 'sequence_number_offset', 'event_limit'],
          'additionalProperties': false
        }
      }
    }
  end

  def _fetch_response_payload_schema
    {
      '$schema': JSON_SCHEMA,
      'type': 'object',
      'properties': {
        'ecosystem_event_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/ecosystem_event_response'},
          'minItems': 0,
          'maxItems': 100
        },
      },
      'required': ['ecosystem_event_responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'ecosystem_event_response': {
          'type': 'object',
          'properties': {
            'request_uuid':   {'$ref': '#standard_definitions/uuid'},
            'ecosystem_uuid': {'$ref': '#standard_definitions/uuid'},
            'events': {
              'type': 'array',
              'items': {
                'type': 'object',
                'properties': {
                  'sequence_number': {'$ref': '#standard_definitions/non_negative_integer'},
                  'event_uuid':      {'$ref': '#standard_definitions/uuid'},
                  'event_type':      {'$ref': '#standard_definitions/ecosystem_event_type'},
                  'event_data':      {'$ref': '#standard_definitions/ecosystem_event_data'}
                },
                'required': ['sequence_number', 'event_uuid', 'event_type', 'event_data'],
                'additionalProperties': false
              },
              'minItems': 0,
              'maxItems': 1000
            },
            'is_stopped_at_gap': {'type': 'boolean'}
          },
          'required': ['ecosystem_uuid', 'events', 'is_stopped_at_gap'],
          'additionalProperties': false
        }
      }
    }
  end

end
