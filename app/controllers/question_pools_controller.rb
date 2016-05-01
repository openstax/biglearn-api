class QuestionPoolsController < JsonApiController

  def create
    with_json_apis(input_schema:  _create_request_payload_schema,
                   output_schema: _create_response_payload_schema) do
      question_pool_uuids = _process_question_pool_defs(
        json_parsed_request_payload['question_pool_defs']
      )

      response_payload = { 'question_pool_uuids': question_pool_uuids }
      render json: response_payload.to_json, status: 200
    end
  end


  def _process_question_pool_defs(question_pool_defs)
    ##
    ## validate all question uuids
    ##

    question_uuids = question_pool_defs.collect{ |qpd| qpd['question_uuids'] }
                                     .flatten.uniq
    questions = Question.where{uuid.in question_uuids}
    invalid_question_uuids = question_uuids - questions.collect(&:uuid)
    errors = invalid_question_uuids.collect{ |uuid|
      "invalid question uuid: #{uuid}"
    }
    fail Errors::AppUnprocessableError.new(errors) if errors.any?

    ##
    ## create new question pools
    ##

    question_pool_uuids = question_pool_defs.collect{ SecureRandom.uuid }

    QuestionPool.transaction do
      question_pool_defs.zip(question_pool_uuids).each do |question_pool_def, question_pool_uuid|
        questions = Question.where{uuid.in question_pool_def['question_uuids']}
        question_pool = QuestionPool.create!(uuid: question_pool_uuid, questions: questions)
        question_pool.questions << questions
      end
    end

    question_pool_uuids
  end


  def _create_request_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'question_pool_defs': {
          'type': 'array',
          'items': {'$ref': '#definitions/question_pool_def'},
        },
      },
      'required': ['question_pool_defs'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,

      'definitions': {
        'question_pool_def': {
          'type': 'object',
          'properties': {
            'question_uuids': {
              'type': 'array',
              'items': {'$ref': '#standard_definitions/uuid'},
            },
          },
          'required': ['question_uuids'],
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
        'question_pool_uuids': {
          'type': 'array',
          'items': {'$ref': '#standard_definitions/uuid'}
        },
      },
      'required': ['question_pool_uuids'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,
    }
  end

end
