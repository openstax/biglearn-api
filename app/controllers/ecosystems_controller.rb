class EcosystemsController < JsonApiController

  def create
    with_json_apis(input_schema:  _create_request_payload_schema,
                   output_schema: _create_response_payload_schema) do
      request_payload = json_parsed_request_payload
      ecosystem_data = request_payload.deep_symbolize_keys

      service = Services::CreateEcosystem::Service.new
      created_ecosystem_uuid = service.process(ecosystem_uuid: ecosystem_uuid,
                                               book: book,
                                               exercises: exercises)

      render json: { 'created_ecosystem_uuid': created_ecosystem_uuid }.to_json, status: 201
    end
  end

  protected

  def _create_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'ecosystem_uuid': {'$ref': '#standard_definitions/uuid'},
        'book': {
          'cnx_identity': {'$ref': '#standard_definitions/cnx_identity'},
          'contents': {
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'container_uuid':         {'$ref': '#standard_definitions/uuid'},
                'container_parent_uuid':  {'$ref': '#standard_definitions/uuid'},
                ## NOTE: optional
                'container_cnx_identity': {'$ref': '#standard_definitions/cnx_identity'},
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
              'items': {'$ref': '#standard_definitions/uuid'},
              'minItems': 0,
              'maxItems': 500,
            },
          },
          'required': ['use_for_clue', 'use_for_personalized_for_assignment_types', 'exercise_uuids'],
          'additionalProperties': false,
        },
        'exercise': {
          'type': 'object',
          'properties': {
            'uuid':              {'$ref': '#standard_definitions/uuid'},
            'exercises_uuid':    {'$ref': '#standard_definitions/uuid'},
            'exercises_version': {'$ref': '#standard_definitions/non_negative_integer'},
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
        'created_ecosystem_uuid': {'$ref': '#standard_definitions/uuid'},
      },
      'required': ['created_ecosystem_uuid'],
      'additionalProperties': false,
    }
  end

end
