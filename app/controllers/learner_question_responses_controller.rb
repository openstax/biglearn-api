class LearnerQuestionResponsesController < JsonApiController

  def create
    with_json_apis(input_schema:  _create_request_payload_schema,
                   output_schema: _create_response_payload_schema) do
      request_payload = json_parsed_request_payload

      num_created_responses = _process_responses(request_payload['learner_question_response_defs'])

      render json: {'num_created_responses': num_created_responses}.to_json, status: 200
    end
  end


  def _process_responses(entries)
    ##
    ## validate all learner and question uuids
    ##

    learner_uuids = entries.collect{ |entry| entry['learner_uuid'] }.uniq
    learners = Learner.where{uuid.in learner_uuids}
    invalid_learner_uuids = learner_uuids - learners.collect(&:uuid)
    learner_errors = invalid_learner_uuids.collect{ |uuid|
      "invalid learner uuid: #{uuid}"
    }

    question_uuids = entries.collect{ |entry| entry['question_uuid'] }.uniq
    questions = Question.where{uuid.in question_uuids}
    invalid_question_uuids = question_uuids - questions.collect(&:uuid)
    question_errors = invalid_question_uuids.collect{ |uuid|
      "invalid question uuid: #{uuid}"
    }

    errors = learner_errors + question_errors
    fail Errors::AppUnprocessableError.new(errors) if errors.any?

    ##
    ## create the LearnerQuestionResponses
    ##

    learner_question_responses = LearnerQuestionResponse.transaction(isolation: :serializable) do
      learner_question_responses = entries.each do |entry|
        learner_uuid  = entry['learner_uuid']
        question_uuid = entry['question_uuid']
        response      = entry['response']

        learner_question_response = LearnerQuestionResponse.create!(
          uuid: SecureRandom.uuid.to_s,
          learner_uuid:  learner_uuid,
          question_uuid: question_uuid,
          correct:       response == 'correct',
        )

        learner_question_response
      end
    end

    learner_question_responses.count
  end


  def _create_request_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'learner_question_response_defs': {
          'type': 'array',
          'items': { '$ref': '#/definitions/learner_question_response_def' }
        },
      },
      'required': ['learner_question_response_defs'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,

      'definitions': {
        'learner_question_response_def': {
          'type': 'object',
          'properties': {
            'learner_uuid':  { '$ref': '#/standard_definitions/uuid' },
            'question_uuid': { '#ref': '#/standard_definitions/uuid' },
            'response': {
              'type': 'string',
              'enum': ['correct', 'incorrect'],
            },
          },
          'required': ['learner_uuid', 'question_uuid', 'response'],
          'additionalProperties': false,
        },
      },
    }
  end


  def _create_response_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'num_created_responses': { '$ref': '#standard_definitions/non_negative_integer' },
      },
      'required': ['num_created_responses'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,
    }
  end

end
