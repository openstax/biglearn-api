class PrecomputedCluesController < ApplicationController

  def retrieve
    with_json_apis(input_schema:      _retrieve_request_payload_schema,
                   output_schema_map: { 200 => _retrieve_response_200_payload_schema,
                                        422 => _generic_error_schema }) do
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
        precomputed_clues << _create_random_clue
      else
        errors << "invalid precomputed_clue_uuid: #{uuid}"
      end
    end

    [errors, precomputed_clues]
  end


  def _create_random_clue
    left, aggregate, right = [Random.rand(1.0), Random.rand(1.0), Random.rand(1.0)].sort
    unique_learner_count, sample_size = [1+Random.rand(10), 1+Random.rand(10)].sort
    {
      'aggregate': aggregate,
      'confidence': {
        'left':  left,
        'right': right,
        'sample_size': sample_size,
        'unique_learner_count': unique_learner_count,
      },
      'interpretation': {
        'confidence': ['good', 'bad'].sample,
        'level': ['low', 'medium', 'high'].sample,
        'threshold': ['above', 'below'].sample,
      },
    }
  end


  def _retrieve_request_payload_schema
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

      'standard_definitions': _standard_definitions,
    }
  end


  def _retrieve_response_200_payload_schema
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

      'standard_definitions': _standard_definitions,

      'definitions': {
        'clue': {
          'type': 'object',
          'properties': {
            'aggregate': {'$ref': '#standard_definitions/number_between_0_and_1'},
            'confidence': {
              'type': 'object',
              'properties': {
                'left':  {'$ref': '#standard_definitions/number_between_0_and_1'},
                'right': {'$ref': '#standard_definitions/number_between_0_and_1'},
                'sample_size': {'$ref': '#standard_definitions/non_negative_integer'},
                'unique_learner_count': {'$ref': '#standard_definitions/non_negative_integer'},
              },
              'required': ['left', 'right', 'sample_size', 'unique_learner_count'],
              'additionProperties': false,
            },
            'interpretation': {
              'type': 'object',
              'properties': {
                'confidence': {'enum': ['good', 'bad']},
                'level': {'enum': ['low', 'medium', 'high']},
                'threshold': {'enum': ['above', 'below']},
              },
              'required': ['confidence', 'level', 'threshold'],
              'additionProperties': false,
            },
          },
          'required': ['aggregate', 'confidence', 'interpretation'],
          'additionProperties': false,
        },
      },
    }
  end

end
