class PrecomputedCluesController < JsonApiController

  def retrieve
    with_json_apis(input_schema:  _retrieve_request_payload_schema,
                   output_schema: _retrieve_response_payload_schema) do
      precomputed_clues = _process_precomputed_clue_uuids(
        json_parsed_request_payload['precomputed_clue_uuids']
      )

      response_payload = { 'precomputed_clues': precomputed_clues }
      render json: response_payload.to_json, status: 200
    end
  end


  def _process_precomputed_clue_uuids(precomputed_clue_uuids)
    valid_precomputed_clue_uuids = [
      "50fa8fc6-0974-4448-a730-880165a702fe",
      "5913c263-f91d-4c83-af62-19d4619117f5",
      "38a89013-57da-4189-8534-d68db933776b",
      "7d2e17bd-50ff-4f80-a62b-a1f4e1dd6990",
      "5c04044c-f546-477a-8341-4f32cdc28618"
    ]

    errors            = []
    precomputed_clues = []

    precomputed_clue_uuids.each_with_index do |uuid, idx|
      if valid_precomputed_clue_uuids.include? uuid
        precomputed_clues << _create_random_clue
      else
        errors << "invalid precomputed_clue_uuid: #{uuid}"
      end
    end

    fail Errors::AppUnprocessableError.new(errors) if errors.any?

    precomputed_clues
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


  def _retrieve_response_payload_schema
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
