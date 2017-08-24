class EcosystemsController < JsonApiController

  def create
    respond_with_json_apis_and_service(
      input_schema:  _create_request_payload_schema,
      output_schema: _create_response_payload_schema,
      service: Services::CreateEcosystem::Service
    )
  end

  def fetch_metadatas
    respond_with_json_apis_and_service(
      output_schema: _fetch_metadatas_response_payload_schema,
      service: Services::FetchEcosystemMetadatas::Service
    )
  end

  def fetch_events
    respond_with_json_apis_and_service(
      input_schema:  _fetch_events_request_payload_schema,
      output_schema: _fetch_events_response_payload_schema,
      service: Services::FetchEcosystemEvents::Service
    )
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
                }
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
        'imported_at': {'$ref': '#/standard_definitions/datetime'}
      },
      'required': ['ecosystem_uuid', 'book', 'exercises', 'imported_at'],
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
            'exercise_uuid': {'$ref': '#/standard_definitions/uuid'},
            'group_uuid':    {'$ref': '#/standard_definitions/uuid'},
            'version':       {'$ref': '#/standard_definitions/non_negative_integer'},
            'los': {
              'type': 'array',
              'items': {'$ref': '#definitions/lo'},
              'minItems': 1,
              'maxItems': 100,
            },
          },
          'required': ['exercise_uuid', 'group_uuid', 'version', 'los'],
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
            'uuid': {'$ref': '#/standard_definitions/uuid'}
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
          'maxItems': 1000
        },
        'max_num_events': {
          'type': 'integer',
          'minimum': 1,
          'maximum': 1000
        }
      },
      'required': ['ecosystem_event_requests', 'max_num_events'],
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
            'sequence_number_offset': {'$ref': '#standard_definitions/non_negative_integer'}
          },
          'required': ['request_uuid', 'ecosystem_uuid', 'sequence_number_offset'],
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
          'maxItems': 1000
        }
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
            'is_gap': {'type': 'boolean'},
            'is_end': {'type': 'boolean'}
          },
          'required': ['request_uuid', 'ecosystem_uuid', 'events', 'is_gap', 'is_end'],
          'additionalProperties': false
        }
      }
    }
  end

end
