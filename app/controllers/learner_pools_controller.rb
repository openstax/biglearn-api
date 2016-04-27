class LearnerPoolsController < ApplicationController

  def create
    with_json_apis(input_schema: _create_request_payload_schema,
                   output_schema_map: { 200 => _create_response_200_payload_schema,
                                        422 => _generic_error_schema }) do
      request_payload = json_parsed_request_payload

      learner_pool_uuids = request_payload['learner_pool_defs'].collect{ SecureRandom.uuid.to_s }

      render json: {'learner_pool_uuids': learner_pool_uuids}.to_json, status: 200
    end
  end


  def _create_request_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'learner_pool_defs': {
          'type': 'array',
          'items': {'$ref': '#definitions/learner_pool_def'},
        },
      },
      'required': ['learner_pool_defs'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,

      'definitions': {
        'learner_pool_def': {
          'type': 'object',
          'properties': {
            'learner_uuids': {
              'type': 'array',
              'items': {'$ref': '#standard_definitions/uuid'},
            },
          },
          'required': ['learner_uuids'],
          'additionalProperties': false,
        },
      },
    }
  end

  def _create_response_200_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'learner_pool_uuids': {
          'type': 'array',
          'items': {'$ref': '#standard_definitions/uuid'}
        },
      },
      'required': ['learner_pool_uuids'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,
    }
  end

end
