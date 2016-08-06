class TrialsController < JsonApiController
  def record_responses
    with_json_apis(input_schema:  _record_responses_request_payload_schema,
                   output_schema: _record_responses_response_payload_schema) do
      request_payload = json_parsed_request_payload

      results = _process_trial_responses(request_payload['responses'])

      response_payload = {
        'saved_response_uuids':       results[:saved_response_uuids],
        'ignored_response_uuids':     results[:ignored_response_uuids],
        'newly_saved_response_uuids': results[:newly_saved_response_uuids],
      }
      render json: response_payload.to_json, status: 200
    end
  end


  def _process_trial_responses(trial_response_params)
    saved_response_uuids, newly_saved_response_uuids, ignored_response_uuids =
      if trial_response_params.none?
        [[], [], []]
      else
        keys = [:response_uuid, :trial_uuid, :learner_uuid, :question_uuid, :is_correct]

        key_str = (keys + [:created_at, :updated_at]).map(&:to_s)
                                                     .join(',')
                                                     .prepend('(')
                                                     .concat(')')

        current_time_str = Time.now.strftime('%Y-%m-%d %H:%M:%S.%6N %z')

        values_str = trial_response_params.map{ |params|
          keys.map(&:to_s)
              .map{|key| "'#{params[key]}'"}
              .concat(["'#{current_time_str}'", "'#{current_time_str}'"])
              .join(',')
              .prepend('(')
              .concat(')')
        }.join(',')

        newly_saved_response_uuids = TrialResponse.connection.execute(
          "INSERT INTO trial_responses #{key_str} " +
          "VALUES #{values_str} " +
          "ON CONFLICT DO NOTHING " +
          "RETURNING * "
        ).map{|hash| hash['response_uuid']}

        target_response_uuids = trial_response_params.map{|params| params['response_uuid']}.uniq

        saved_response_uuids = TrialResponse.where{response_uuid.in target_response_uuids}
                                            .pluck(:response_uuid)
        ignored_response_uuids = target_response_uuids - newly_saved_response_uuids

        [saved_response_uuids, newly_saved_response_uuids, ignored_response_uuids]
      end

    results = {
      saved_response_uuids:       saved_response_uuids,
      newly_saved_response_uuids: newly_saved_response_uuids,
      ignored_response_uuids:     ignored_response_uuids,
    }

    results
  end


  def _record_responses_request_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/response_def'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['responses'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,

      'definitions': {
        'response_def': {
          'type': 'object',
          'properties': {
            'trial_uuid':    {'$ref': '#standard_definitions/uuid'},
            'response_uuid': {'$ref': '#standard_definitions/uuid'},
            'learner_uuid':  {'$ref': '#standard_definitions/uuid'},
            'question_uuid': {'$ref': '#standard_definitions/uuid'},
            'is_correct': {
              'type': 'string',
              'enum': ['true', 'false'],
            },
          },
          'required': [
            'trial_uuid',
            'response_uuid',
            'learner_uuid',
            'question_uuid',
            'is_correct'
            ],
          'additionalProperties': false,
        },
      },

    }
  end

  def _record_responses_response_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'saved_response_uuids': {
          'type': 'array',
          'items': {'$ref': '#standard_definitions/uuid'},
          'minItems': 0,
        },
        'newly_saved_response_uuids': {
          'type': 'array',
          'items': {'$ref': '#standard_definitions/uuid'},
          'minItems': 0,
        },
        'ignored_response_uuids': {
          'type': 'array',
          'items': {'$ref': '#standard_definitions/uuid'},
          'minItems': 0,
        },
      },
      'required': ['saved_response_uuids', 'newly_saved_response_uuids', 'ignored_response_uuids'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,
    }
  end
end
