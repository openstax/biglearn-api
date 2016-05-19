class ConceptsController < JsonApiController

  def create
    with_json_apis(input_schema:  _create_request_payload_schema,
                   output_schema: _create_response_payload_schema) do
      request_payload = json_parsed_request_payload

      concept_uuids = _process_count(request_payload['count'])

      render json: {'concept_uuids': concept_uuids}.to_json, status: 200
    end
  end


  def _process_count(count)
    concept_uuids = count.times.collect{ SecureRandom.uuid.to_s }

    Concept.transaction(requires_new: true) do
      concept_uuids.collect{ |uuid| Concept.create!(uuid: uuid) }
    end

    concept_uuids
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
        'concept_uuids': {
          'type': 'array',
          'items': {'$ref': '#standard_definitions/uuid'},
        },
      },
      'required': ['concept_uuids'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,
    }
  end

end
