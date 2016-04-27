class PrecomputedCluesController < ApplicationController

  def retrieve
    with_json_apis(input_schema:      retrieve_request_payload_schema,
                   output_schema_map: { 200 => retrieve_response_200_payload_schema,
                                        422 => generic_error_schema }) do
      payload = { 'errors': ['invalid precomputed clue uuid'] }
      render json: payload.to_json, status: 422
    end
  end

  def retrieve_request_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'precomputed_clue_uuids': {
          'type': 'array',
          'items': {'$ref': '#standard_definitions/uuid'},
          'uniqueItems': true,
        },
      },
      'required': ['precomputed_clue_uuids'],
      'additionProperties': false,

      'standard_definitions': standard_definitions,
    }
  end

  def retrieve_response_200_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'precomputed_clues': {
          'type': 'array',
          'items': {
            'type': '#definitions/clue',
          },
        },
      },
      'required': ['precomputed_clues'],
      'additionProperties': false,

      'standard_definitions': standard_definitions,
      'definitions': {
        'clue': {
          'type': 'string',
        },
      },
    }
  end
end
