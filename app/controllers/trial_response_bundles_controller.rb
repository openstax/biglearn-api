class TrialResponseBundlesController < JsonApiController
  def fetch
    with_json_apis(input_schema:  _fetch_request_payload_schema,
                   output_schema: _fetch_response_payload_schema) do
      request_payload = json_parsed_request_payload

      results = _fetch_bundles(
        receiver_uuid:          request_payload['receiver_uuid'],
        receiver_modulo:        request_payload['receiver_modulo'],
        receiver_count:         request_payload['receiver_count'],
        max_bundle_count:       request_payload['max_bundle_count'],
        confirmed_bundle_uuids: request_payload['confirmed_bundle_uuids'],
      )

      response_payload = {
        'bundles':                      results[:bundles],
        'confirmed_bundle_uuids':       results[:confirmed_bundle_uuids],
        'newly_confirmed_bundle_uuids': results[:newly_confirmed_bundle_uuids],
        'ignored_bundle_uuids':         results[:ignored_bundle_uuids],
      }
      render json: response_payload.to_json, status: 200
    end
  end


  def _fetch_bundles(receiver_uuid:,
                     receiver_modulo:,
                     receiver_count:,
                     max_bundle_count:,
                     confirmed_bundle_uuids:)
    # unsent_or_unconf_trial_response_bundle_uuids = TrialResponseBundle.connection.execute(
    #   'SELECT uuid FROM ' +
    #   'trial_response_bundles FULL JOIN trial_response_bundle_receipts ' +
    #   'ON trial_response_bundles.uuid = trial_response_bundle_receipts.trial_response_bundle_uuid ' +
    #   'WHERE trial_response_bundle_receipts.trial_response_bundle_uuid IS NULL ' +
    #   'OR trial_response_bundles.is_open IS TRUE ' +
    #   'OR trial_response_bundle_receipts.is_confirmed IS FALSE '
    # ).map{|hash| hash['uuid']}

    results = {
      bundles:                      [],
      confirmed_bundle_uuids:       [],
      newly_confirmed_bundle_uuids: [],
      ignored_bundle_uuids:         confirmed_bundle_uuids,
    }

    results
  end

  def _fetch_request_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'receiver_uuid':   {'$ref': '#standard_definitions/uuid'},
        'receiver_modulo': {'$ref': '#standard_definitions/non_negative_integer'},
        'receiver_count':  {'$ref': '#standard_definitions/non_negative_integer'},
        'max_bundle_count': {
          'type': 'integer',
          'minimum':   0,
          'maximum': 100,
        },
        'confirmed_bundle_uuids': {
          'type': 'array',
          'items': {'$ref': '#standard_definitions/uuid'},
          'minItems': 0,
          'maxItems': 100,
        },
      },
      'required': [
        'receiver_uuid',
        'receiver_modulo',
        'receiver_count',
        'max_bundle_count',
        'confirmed_bundle_uuids'
      ],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,
    }
  end


  def _fetch_response_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'bundles': {
          'type': 'array',
          'items': {'$ref': '#definitions/bundle_def'},
          'minItems': 0,
        },
        'confirmed_bundle_uuids': {
          'type': 'array',
          'items': {'$ref': '#standard_definitions/uuid'},
          'minItems': 0,
        },
        'newly_confirmed_bundle_uuids': {
          'type': 'array',
          'items': {'$ref': '#standard_definitions/uuid'},
          'minItems': 0,
        },
        'ignored_bundle_uuids': {
          'type': 'array',
          'items': {'$ref': '#standard_definitions/uuid'},
          'minItems': 0,
        },
      },
      'required': [
        'bundles',
        'confirmed_bundle_uuids',
        'newly_confirmed_bundle_uuids',
        'ignored_bundle_uuids'
      ],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,

      'definitions': {
        'bundle_def': {
          'type': 'object',
          'properties': {
            'bundle_uuid': {'$ref': '#standard_definitions/uuid'},
            'bundle_state': {
              'type': 'string',
              'enum': ['open', 'closed'],
            },
            'trial_responses': {
              'type': 'array',
              'items': {'$ref': '#definitions/response_def'},
              'minItems': 0,
            },
          },
          'required': ['bundle_uuid', 'trial_responses'],
          'additionalProperties': false,
        },
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

end
