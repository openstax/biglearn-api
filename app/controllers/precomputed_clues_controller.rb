class PrecomputedCluesController < ApplicationController

  def retrieve
    with_json_apis(input_schema:      retrieve_request_payload_schema,
                   output_schema_map: { 200 => retrieve_response_200_payload_schema,
                                        422 => generic_error_schema }) do
      errors, precomputed_clues = _process_precomputed_clue_uuids(
        json_parsed_request_payload['precomputed_clue_uuids']
      )

      response_status, response_payload =
        if errors.any?
          [422, { 'errors': errors }]
        else
          [200, { 'precomputed_clues': precomputed_clues }]
        end

      render json: response_payload.to_json, status: response_status
    end
  end

  def _process_precomputed_clue_uuids(precomputed_clue_uuids)
    errors            = []
    precomputed_clues = []

    valid_precomputed_clue_uuids = [
      "50fa8fc6-0974-4448-a730-880165a702fe",
      "5913c263-f91d-4c83-af62-19d4619117f5",
      "38a89013-57da-4189-8534-d68db933776b",
      "7d2e17bd-50ff-4f80-a62b-a1f4e1dd6990",
      "5c04044c-f546-477a-8341-4f32cdc28618"
    ]

    precomputed_clue_uuids.each_with_index do |uuid, idx|
      if valid_precomputed_clue_uuids.include? uuid
        precomputed_clues << "PCP for #{uuid} = #{idx}"
      else
        errors << "invalid precomputed_clue_uuid: #{uuid}"
      end
    end

    [errors, precomputed_clues]
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
          'items': {'$ref': '#definitions/clue'},
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
