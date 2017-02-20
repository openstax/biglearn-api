class EcosystemsController < JsonApiController

  def create
    with_json_apis(input_schema:  _create_request_payload_schema,
                   output_schema: _create_response_payload_schema) do
      ecosystem_data = json_parsed_request_payload

      service = Services::CreateEcosystem::Service.new
      result = service.process(ecosystem_uuid: ecosystem_data.fetch(:ecosystem_uuid),
                               book: ecosystem_data.fetch(:book),
                               exercises: ecosystem_data.fetch(:exercises))

      response_payload = { created_ecosystem_uuid: result.fetch(:created_ecosystem_uuid) }

      render json: response_payload.to_json, status: 200
    end
  end

  def fetch_metadatas
    with_json_apis(output_schema: _fetch_metadatas_response_payload_schema) do

      service = Services::FetchEcosystemMetadatas::Service.new
      result = service.process()

      response_payload = { ecosystem_responses: result.fetch(:ecosystem_responses) }
      render json: response_payload.to_json, status: 200
    end
  end

  def fetch_events
    with_json_apis(input_schema:  _fetch_events_request_payload_schema,
                   output_schema: _fetch_events_response_payload_schema) do
      event_requests = json_parsed_request_payload.fetch(:ecosystem_event_requests)

      service = Services::FetchEcosystemEvents::Service.new
      response_payload = service.process(ecosystem_event_requests: event_requests)

      render json: response_payload.to_json, status: 200
    end
  end

  protected

  def _create_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'ecosystem_uuid': {'$ref': '#/standard_definitions/uuid'},
        'book': {
          'cnx_identity': {'$ref': '#/standard_definitions/cnx_identity'},
          'contents': {
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'container_uuid':         {'$ref': '#/standard_definitions/uuid'},
                'container_parent_uuid':  {'$ref': '#/standard_definitions/uuid'},
                ## NOTE: optional
                'container_cnx_identity': {'$ref': '#/standard_definitions/cnx_identity'},
                'pools': {
                  'type': 'array',
                  'items': {'$ref': '#definitions/pool'},
                  'minItems': 0,
                  'maxItems': 20,
                },
              },
              'required': ['container_uuid', 'container_parent_uuid', 'pools'],
              'additionalProperties': false,
            },
            'minItems': 1,
            'maxItems': 500,
          },
        },
        'exercises': {
          'type': 'array',
          'items': {'$ref': '#definitions/exercise'},
          'minItems': 0,
          'maxItems': 10000,
        },
      },
      'required': ['ecosystem_uuid', 'book', 'exercises'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'pool': {
          'type': 'object',
          'properties': {
            'use_for_clue': {
              'type': 'boolean',
            },
            'use_for_personalized_for_assignment_types': {
              'type': 'array',
              'items': {
                'type': 'string',
                'minLength': 3,
                'maxLength': 100,
              },
              'minItems': 0,
              'maxItems': 20,
            },
            'exercise_uuids': {
              'type': 'array',
              'items': {'$ref': '#/standard_definitions/uuid'},
              'minItems': 0,
              'maxItems': 500,
            },
          },
          'required': [
            'use_for_clue',
            'use_for_personalized_for_assignment_types',
            'exercise_uuids'
          ],
          'additionalProperties': false,
        },
        'exercise': {
          'type': 'object',
          'properties': {
            'uuid':              {'$ref': '#/standard_definitions/uuid'},
            'exercises_uuid':    {'$ref': '#/standard_definitions/uuid'},
            'exercises_version': {'$ref': '#/standard_definitions/non_negative_integer'},
            'los': {
              'type': 'array',
              'items': {'$ref': '#definitions/lo'},
              'minItems': 1,
              'maxItems': 10,
            },
          },
          'required': ['uuid', 'exercises_uuid', 'exercises_version', 'los'],
          'additionalProperties': false,
        },
        'lo': {
          'type': 'string',
          'minLength': 1,
          'maxLength': 100,
        },
      },
    }
  end


  def _create_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'created_ecosystem_uuid': {'$ref': '#/standard_definitions/uuid'},
      },
      'required': ['created_ecosystem_uuid'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions
    }
  end

  def _fetch_metadatas_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'ecosystem_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/ecosystem_metadata'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['ecosystem_responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'ecosystem_metadata': {
          'type': 'object',
          'properties': {
            'uuid': {'$ref': '#/standard_definitions/uuid'},
            'cnx_identity': {'$ref': '#/standard_definitions/cnx_identity'}
          },
          'required': ['uuid'],
          'additionalProperties': false
        }
      }
    }
  end

  def _fetch_events_request_payload_schema
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
          'required': ['request_uuid', 'ecosystem_uuid', 'sequence_number_offset', 'event_limit'],
          'additionalProperties': false
        }
      }
    }
  end

  def _fetch_events_response_payload_schema
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
          'required': ['request_uuid', 'ecosystem_uuid', 'events', 'is_stopped_at_gap'],
          'additionalProperties': false
        }
      }
    }
  end

end
