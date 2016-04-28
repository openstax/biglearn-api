class LearnersController < ApplicationController

  def create
    with_json_apis(input_schema: _create_request_payload_schema,
                   output_schema_map: { 200 => _create_response_200_payload_schema,
                                        422 => _generic_error_schema }) do
      request_payload = json_parsed_request_payload

      errors, learner_uuids = _process_count(request_payload['count'])
      if errors.any?
        render json: {'errors': errors }.to_json, status: 422
      else
        render json: {'learner_uuids': learner_uuids}.to_json, status: 200
      end
    end
  end


  def _process_count(count)
    learner_uuids = count.times.collect{ SecureRandom.uuid.to_s }

    Learner.transaction do
      learner_uuids.collect{ |uuid| Learner.create!(uuid: uuid) }
    end

    [[], learner_uuids]
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


  def _create_response_200_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'learner_uuids': {
          'type': 'array',
          'items': {'$ref': '#standard_definitions/uuid'},
        },
      },
      'required': ['learner_uuids'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,
    }
  end

end
