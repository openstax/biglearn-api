class QuestionsController < JsonApiController

  def create
    with_json_apis(input_schema:  _create_request_payload_schema,
                   output_schema: _create_response_payload_schema) do
      request_payload = json_parsed_request_payload

      question_uuids = _process_count(request_payload['count'])

      render json: {'question_uuids': question_uuids}.to_json, status: 200
    end
  end


  def _process_count(count)
    question_uuids = count.times.collect{ SecureRandom.uuid.to_s }

    Question.transaction(requires_new: true) do
      question_uuids.collect{ |uuid| Question.create!(uuid: uuid) }
    end

    question_uuids
  end


  def _create_request_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'count': {'$ref': '#standard_definitions/non_negative_integer'},
      },
      'required': ['count'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,
    }
  end


  def _create_response_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'question_uuids': {
          'type': 'array',
          'items': {'$ref': '#standard_definitions/uuid'},
        },
      },
      'required': ['question_uuids'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,
    }
  end

end
