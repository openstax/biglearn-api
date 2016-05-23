class LearnerPoolsController < JsonApiController

  def create
    with_json_apis(input_schema:  _create_request_payload_schema,
                   output_schema: _create_response_payload_schema) do
      learner_pool_uuids = _process_learner_pool_defs(
        json_parsed_request_payload['learner_pool_defs']
      )

      response_payload = { 'learner_pool_uuids': learner_pool_uuids }
      render json: response_payload.to_json, status: 200
    end
  end


  def _process_learner_pool_defs(learner_pool_defs)
    ##
    ## validate all learner uuids
    ##

    lpd_learner_uuids = learner_pool_defs.collect{ |lpd| lpd['learner_uuids'] }
                                         .flatten.uniq
    db_learner_uuids = Learner.where{uuid.in lpd_learner_uuids}.collect(&:uuid)
    invalid_learner_uuids = lpd_learner_uuids - db_learner_uuids
    errors = invalid_learner_uuids.collect{ |uuid|
      "invalid learner uuid: #{uuid}"
    }
    fail Errors::AppUnprocessableError.new(errors) if errors.any?

    ##
    ## create new learner pools and associated entries
    ##

    learner_pool_uuids = learner_pool_defs.collect{ SecureRandom.uuid }

    LearnerPool.transaction(requires_new: true) do
      learner_pool_defs.zip(learner_pool_uuids).each do |learner_pool_def, learner_pool_uuid|
        learner_pool = LearnerPool.create!(uuid: learner_pool_uuid)

        learner_pool_def['learner_uuids'].each do |learner_uuid|
          learner_pool_learner = LearnerPoolEntry.create!(
            learner_pool_uuid: learner_pool.uuid,
            learner_uuid:      learner_uuid
          )
        end
      end
    end

    learner_pool_uuids
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

  def _create_response_payload_schema
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
