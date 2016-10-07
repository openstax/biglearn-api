class ResponseBundlesController < JsonApiController

  def fetch
    with_json_apis(input_schema:  _fetch_request_payload_schema,
                   output_schema: _fetch_response_payload_schema) do
      request_payload = json_parsed_request_payload

      goal_max_responses_to_return = request_payload.fetch('goal_max_responses_to_return')
      bundle_uuids_to_confirm      = request_payload.fetch('bundle_uuids_to_confirm')
      receiver_uuid                = request_payload.fetch('receiver_info').fetch('receiver_uuid')
      partition_count              = request_payload.fetch('receiver_info').fetch('partition_count')
      partition_modulo             = request_payload.fetch('receiver_info').fetch('partition_modulo')

      service = Services::FetchResponseBundles::Service.new

      results = service.process(
        goal_max_responses_to_return: goal_max_responses_to_return,
        max_bundles_to_process:       1000,
        bundle_uuids_to_confirm:      bundle_uuids_to_confirm,
        receiver_uuid:                receiver_uuid,
        partition_count:              partition_count,
        partition_modulo:             partition_modulo,
      )

      response_payload = {
        confirmed_bundle_uuids: results.fetch(:confirmed_bundle_uuids),
        bundle_uuids:           results.fetch(:bundle_uuids),
        responses:              results.fetch(:response_data),
      }

      render json: response_payload.to_json, status: 200
    end
  end


  def _fetch_request_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'goal_max_responses_to_return': {
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000,
        },
        'bundle_uuids_to_confirm': {
          'type': 'array',
          'items': {'$ref': '#/standard_definitions/uuid'},
          'minItems': 0,
          'maxItems': 1000,
        },
        'receiver_info': {'$ref': '#/standard_definitions/receiver_info'},
      },
      'required': [
        'goal_max_responses_to_return',
        'bundle_uuids_to_confirm',
        'receiver_info',
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
        'confirmed_bundle_uuids': {
          'type': 'array',
          'items': {'$ref': '#/standard_definitions/uuid'},
          'minItems': 0,
          'maxItems': 1000,
        },
        'bundle_uuids': {
          'type': 'array',
          'items': {'$ref': '#/standard_definitions/uuid'},
          'minItems': 0,
          'maxItems': 1000,
        },
        'responses': {
          'type': 'array',
          'items': {'$ref': '#/definitions/response'},
          'minItems': 0,
        },
      },
      'required': ['confirmed_bundle_uuids', 'bundle_uuids', 'responses'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,

      'definitions': {
        'response': {
          'type': 'object',
          'properties': {
            'response_uuid':  {'$ref': '#/standard_definitions/uuid'},
            'trial_uuid':     {'$ref': '#/standard_definitions/uuid'},
            'trial_sequence': {'$ref': '#/standard_definitions/non_negative_integer'},
            'learner_uuid':   {'$ref': '#/standard_definitions/uuid'},
            'question_uuid':  {'$ref': '#/standard_definitions/uuid'},
            'is_correct':     {'type': 'boolean'},
            'responded_at':   {'$ref': '#/standard_definitions/datetime'},
          },
          'required': [
            'response_uuid',
            'trial_uuid',
            'trial_sequence',
            'learner_uuid',
            'question_uuid',
            'is_correct',
            'responded_at',
          ],
          'additionalProperties': false,
        },
      },
    }
  end


end
