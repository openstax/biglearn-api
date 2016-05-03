class PrecomputedCluesController < JsonApiController

  def create
    with_json_apis(input_schema:  _create_request_payload_schema,
                   output_schema: _create_response_payload_schema) do
      precomputed_clue_uuids = _process_precomputed_clue_defs(
        json_parsed_request_payload['precomputed_clue_defs']
      )

      response_payload = { 'precomputed_clue_uuids': precomputed_clue_uuids }
      render json: response_payload.to_json, status: 200
    end
  end


  def retrieve
    with_json_apis(input_schema:  _retrieve_request_payload_schema,
                   output_schema: _retrieve_response_payload_schema) do
      clues = _process_precomputed_clue_uuids(
        json_parsed_request_payload['precomputed_clue_uuids']
      )

      response_payload = { 'precomputed_clues': clues }
      render json: response_payload.to_json, status: 200
    end
  end


  def _process_precomputed_clue_defs(precomputed_clue_defs)
    precomputed_clue_uuids = precomputed_clue_defs.collect{ SecureRandom.uuid.to_s }

    PrecomputedClue.transaction(requires_new: true) do
      precomputed_clue_uuids.zip(precomputed_clue_defs).each do |precomputed_clue_uuid, precomputed_clue_def|
        learner_pool  = LearnerPool.where{uuid == precomputed_clue_def['learner_pool_uuid']}.first
        question_pool = QuestionPool.where{uuid == precomputed_clue_def['question_pool_uuid']}.first

        clue = Clue.create!(
          uuid:                 SecureRandom.uuid.to_s,
          aggregate:            0.5,
          left:                 0.0,
          right:                1.0,
          sample_size:            0,
          unique_learner_count: learner_pool.learners.count,
          confidence:           'bad',
          level:                'low',
          threshold:            'below'
        )

        precomputed_clue = PrecomputedClue.create!(
          uuid:             precomputed_clue_uuid,
          learner_pool_id:  learner_pool.id,
          question_pool_id: question_pool.id,
          clue_id:          clue.id
        )
      end
    end

    precomputed_clue_uuids
  rescue StandardError => ex
    raise Errors::AppUnprocessableError.new('could not create precomputed_clues')
  end


  def _process_precomputed_clue_uuids(precomputed_clue_uuids)
    precomputed_clues = PrecomputedClue.where{uuid.in precomputed_clue_uuids}

    invalid_precomputed_clue_uuids = precomputed_clue_uuids - precomputed_clues.collect(&:uuid)
    fail Errors::AppUnprocessableError.new("invalid precomputed_clue_uuids: #{invalid_precomputed_clue_uuids}") \
      if invalid_precomputed_clue_uuids.any?

    clues = precomputed_clues.collect{ |precomputed_clue|
      clue = precomputed_clue.clue

      {
        'aggregate': clue.aggregate,
        'confidence': {
          'left': clue.left,
          'right': clue.right,
          'sample_size': clue.sample_size,
          'unique_learner_count': clue.unique_learner_count
        },
        'interpretation': {
          'confidence': clue.confidence,
          'level': clue.level,
          'threshold': clue.threshold,
        },
      }
    }

    clues
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


  def _create_request_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',
      'id': 'http://openstax.org/schemas/precomputed_clues/create/request_payload',

      'type': 'object',
      'properties': {
        'precomputed_clue_defs': {
          'type': 'array',
          'items': {'$ref': '#definitions/precomputed_clue_def'},
          'uniqueItems': true,
        },
      },
      'required': ['precomputed_clue_defs'],
      'additionProperties': false,

      'standard_definitions': _standard_definitions,

      'definitions': {
        'precomputed_clue_def': {
          'type': 'object',
          'properties': {
            'learner_pool_uuid':  {'$ref': '#standard_definitions/uuid'},
            'question_pool_uuid': {'$ref': '#standard_definitions/uuid'},
          },
          'required': ['learner_pool_uuid', 'question_pool_uuid'],
          'additionProperties': false,
        },
      },
    }
  end


  def _create_response_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',
      'id': 'http://openstax.org/schemas/precomputed_clues/create/response_payload',

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
