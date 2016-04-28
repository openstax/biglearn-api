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
    ##
    ## validate all learner uuids
    ##

    learner_uuids = learner_pool_defs.collect{ |lpd| lpd['learner_uuids'] }
                                     .flatten.uniq
    learners = Learner.where{uuid.in learner_uuids}
    invalid_learner_uuids = learner_uuids - learners.collect(&:uuid)
    errors = invalid_learner_uuids.collect{ |uuid|
      "invalid learner uuid: #{uuid}"
    }
    return [errors, []] if errors.any?

    ##
    ## create new learner pools
    ##

    learner_pool_uuids = learner_pool_defs.collect{ SecureRandom.uuid }

    LearnerPool.transaction do
      learner_pool_defs.zip(learner_pool_uuids).each do |learner_pool_def, learner_pool_uuid|
        learners = Learner.where{uuid.in learner_pool_def['learner_uuids']}
        learner_pool = LearnerPool.create!(uuid: learner_pool_uuid, learners: learners)
        learner_pool.learners << learners
      end
    end

    [[], learner_pool_uuids]
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
