class LearnerPoolsController < ApplicationController

  def create
    with_json_apis(input_schema: _create_request_payload_schema,
                   output_schema_map: { 200 => _create_response_200_payload_schema,
                                        422 => _generic_error_schema }) do
      errors, learner_pool_uuids = _process_learner_pool_defs(
        json_parsed_request_payload['learner_pool_defs']
      )

      response_status, response_payload =
        if errors.any?
          [422, { 'errors': errors }]
        else
          [200, { 'learner_pool_uuids': learner_pool_uuids }]
        end

      render json: response_payload.to_json, status: response_status
    end
  end


  def _process_learner_pool_defs(learner_pool_defs)
    errors             = []
    learner_pool_uuids = []

    valid_learner_uuids = [
      "13ecef9e-f7cf-4445-9744-5849be12739a",
      "8e2e0a45-5e1e-4465-9013-2f17441ab8bc",
      "275fd9ff-025c-4bc6-beb3-feccd7942ca1",
      "89927d1a-14f3-4280-8954-7a6b06dd1ff5",
      "3dcd1679-a83b-48d8-ab09-b3cb635d48cf"
    ]

    learner_pool_defs.each_with_index do |learner_pool_def|
      invalid_learner_uuids = learner_pool_def['learner_uuids'] - valid_learner_uuids
      if invalid_learner_uuids.empty?
        learner_pool_uuids << SecureRandom.uuid.to_s
      else
        invalid_learner_uuids.each do |uuid|
          errors << "invalid learner_uuid: #{uuid}"
        end
      end
    end

    [errors, learner_pool_uuids]
  end


  def _create_request_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'learner_pool_defs': {
          'type': 'array',
          'items': {'$ref': '#definitions/learner_pool_def'},
        },
      },
      'required': ['learner_pool_defs'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,

      'definitions': {
        'learner_pool_def': {
          'type': 'object',
          'properties': {
            'learner_uuids': {
              'type': 'array',
              'items': {'$ref': '#standard_definitions/uuid'},
            },
          },
          'required': ['learner_uuids'],
          'additionalProperties': false,
        },
      },
    }
  end

  def _create_response_200_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'learner_pool_uuids': {
          'type': 'array',
          'items': {'$ref': '#standard_definitions/uuid'}
        },
      },
      'required': ['learner_pool_uuids'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,
    }
  end

end
