class QuestionConceptHintsController < JsonApiController

  def create
    with_json_apis(input_schema:  _create_request_payload_schema,
                   output_schema: _create_response_payload_schema) do
      request_payload = json_parsed_request_payload

      _process_hints(request_payload['question_concept_hint_defs'])

      render json: {'message': 'success'}.to_json, status: 200
    end
  end

  def _process_hints(entries)
    ##
    ## validate all question and concept uuids
    ##

    question_uuids = entries.collect{ |entry| entry['question_uuid'] }.uniq
    questions = Question.where{uuid.in question_uuids}
    invalid_question_uuids = question_uuids - questions.collect(&:uuid)
    question_errors = invalid_question_uuids.collect{ |uuid|
      "invalid question uuid: #{uuid}"
    }

    concept_uuids = entries.collect{ |entry| entry['concept_uuids'] }.flatten.uniq
    concepts = Concept.where{uuid.in concept_uuids}
    invalid_concept_uuids = concept_uuids - concepts.collect(&:uuid)
    concept_errors = invalid_concept_uuids.collect{ |uuid|
      "invalid concept uuid: #{uuid}"
    }

    errors = question_errors + concept_errors
    fail Errors::AppUnprocessableError.new(errors) if errors.any?

    ##
    ## create the QuestionConceptHints (those that don't exist, anyway)
    ##

    QuestionConceptHint.transaction do
      entries.each do |entry|
        question_uuid = entry['question_uuid']
        question = Question.where{uuid == question_uuid}.take!

        concept_uuids = entry['concept_uuids']
        concepts = Concept.where{uuid.in concept_uuids}

        concepts.each do |concept|
          question_concept_hint = QuestionConceptHint.find_or_create_by!(
            question_id: question.id,
            concept_id:  concept.id) do |question_concept_hint|
            question_concept_hint.uuid = SecureRandom.uuid.to_s
          end
        end
      end
    end
  end


  def _create_request_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'question_concept_hint_defs': {
          'type': 'array',
          'items': {
            'type': 'object',
            'properties': {
              'question_uuid': { '$ref': '#/standard_definitions/uuid' },
              'concept_uuids': {
                'type': 'array',
                'items': { '$ref': '#/standard_definitions/uuid' },
                'minItems': 1,
                'uniqueItems': true,
              },
            },
            'required': ['question_uuid', 'concept_uuids'],
            'additionalProperties': false,
          },
        },
      },
      'required': ['question_concept_hint_defs'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,
    }
  end


  def _create_response_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'message': {
          'type': 'string',
        },
      },
      'required': ['message'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,
    }
  end

end
