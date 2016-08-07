class TrialResponseBundlesController < JsonApiController
  def fetch
    with_json_apis(input_schema:  _fetch_request_payload_schema,
                   output_schema: _fetch_response_payload_schema) do
      response_payload = {
        'bundles':                      [],
        'confirmed_bundle_uuids':       [],
        'ignored_bundle_uuids':         [],
        'newly_confirmed_bundle_uuids': [],
      }
      render json: response_payload.to_json, status: 200
    end
  end

  def _fetch_request_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'reader_number': {'$ref': '#standard_definitions/non_negative_integer'},
        'reader_modulo': {'$ref': '#standard_definitions/non_negative_integer'},
        'max_count': {
          'type': 'integer',
          'minimum':   0,
          'maximum': 100,
        },
        'confirmed_bundle_uuids': {
          'type': 'array',
          'items': {'$ref': '#definitions/response_def'},
          'minItems': 0,
          'maxItems': 100,
        },
      },
      'required': [
        'reader_number',
        'reader_modulo',
        'max_count',
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
