class QuestionConceptHintsController < JsonApiController

  def create
    with_json_apis(input_schema:  _create_request_payload_schema,
                   output_schema: _create_response_payload_schema) do
      request_payload = json_parsed_request_payload

      num_created_hints = _process_hints(request_payload['question_concept_hint_defs'])

      render json: {'num_created_hints': num_created_hints}.to_json, status: 200
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

    num_created_hints = 0

    QuestionConceptHint.transaction(requires_new: true) do
      entries.each do |entry|
        question_uuid = entry['question_uuid']
        concept_uuids = entry['concept_uuids']

        concept_uuids.each do |concept_uuid|
          question_concept_hint = QuestionConceptHint.find_or_create_by!(
            question_uuid: question_uuid,
            concept_uuid:  concept_uuid,
          ) do |question_concept_hint|
            question_concept_hint.uuid = SecureRandom.uuid.to_s
            num_created_hints += 1
          end
        end
      end
    end

    num_created_hints
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
        'num_created_hints': { '$ref': '#/standard_definitions/non_negative_integer' },
      },
      'required': ['num_created_hints'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,
    }
  end

end
