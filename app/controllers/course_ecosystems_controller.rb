class CourseEcosystemsController < JsonApiController

  def prepare
    with_json_apis(input_schema:  _prepare_request_payload_schema,
                   output_schema: _prepare_response_payload_schema) do
      request_payload = json_parsed_request_payload
      course_ecosystem_data = request_payload.deep_symbolize_keys

      service = Services::PrepareCourseEcosystem::Service.new
      result = service.process(preparation_uuid: course_ecosystem_data[:preparation_uuid],
                               course_uuid: course_ecosystem_data[:course_uuid],
                               sequence_number: course_ecosystem_data[:sequence_number],
                               next_ecosystem_uuid: course_ecosystem_data[:next_ecosystem_uuid],
                               ecosystem_map: course_ecosystem_data[:ecosystem_map])

      render json: result.slice(:status).to_json, status: 200
    end
  end

  def update
    with_json_apis(input_schema:  _update_request_payload_schema,
                   output_schema: _update_response_payload_schema) do
      request_payload = json_parsed_request_payload
      update_requests_data = request_payload.deep_symbolize_keys[:update_requests]

      service = Services::UpdateCourseEcosystem::Service.new
      results = service.process(update_requests: update_requests_data)

      response_payload = {
        update_responses: results[:update_responses].map do |result|
          result.slice(:request_uuid, :update_status)
        end
      }

      render json: response_payload.to_json, status: 200
    end
  end

  def status
    with_json_apis(input_schema:  _status_request_payload_schema,
                   output_schema: _status_response_payload_schema) do
      request_payload = json_parsed_request_payload
      course_ecosystem_data = request_payload.deep_symbolize_keys

      service = Services::CourseEcosystemStatus::Service.new
      results = service.process(request_uuid: course_ecosystem_data[:request_uuid],
                                course_uuids: course_ecosystem_data[:course_uuids])

      response_payload = {
        course_statuses: results[:course_statuses].map do |result|
          result.slice(
            :course_uuid, :course_is_known, :current_ecosystem_preparation_uuid
          ).merge(
            current_ecosystem_status: result[:current_ecosystem_status].slice(
              :ecosystem_uuid, :ecosystem_is_known,
              :ecosystem_is_prepared, :precompute_is_complete
            ),
            next_ecosystem_status: result[:next_ecosystem_status].slice(
              :ecosystem_uuid, :ecosystem_is_known,
              :ecosystem_is_prepared, :precompute_is_complete
            )
          )
        end
      }

      render json: response_payload.to_json, status: 200
    end
  end

  protected

  def _prepare_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'preparation_uuid':    {'$ref': '#standard_definitions/uuid'},
        'course_uuid':         {'$ref': '#standard_definitions/uuid'},
        'sequence_number':     {'$ref': '#standard_definitions/non_negative_integer'},
        'next_ecosystem_uuid': {'$ref': '#standard_definitions/uuid'},
        'ecosystem_map': {
          'type': 'object',
          'properties': {
            'from_ecosystem_uuid': {'$ref': '#standard_definitions/uuid'},
            'to_ecosystem_uuid':   {'$ref': '#standard_definitions/uuid'},
            'cnx_pagemodule_mappings': {
              'type': 'array',
              'items': {'$ref': '#definitions/cnx_pagemodule_mapping'},
              'minItems': 0,
              'maxItems': 500,
            },
            'exercise_mappings': {
              'type': 'array',
              'items': {'$ref': '#definitions/exercise_mapping'},
              'minItems': 0,
              'maxItems': 10000,
            },
          },
          'required': ['from_ecosystem_uuid', 'to_ecosystem_uuid', 'cnx_pagemodule_mappings', 'exercise_mappings'],
          'additionalProperties': false,
        },
      },
      'required': ['preparation_uuid', 'course_uuid', 'sequence_number', 'next_ecosystem_uuid'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'cnx_pagemodule_mapping': {
          'type': 'object',
          'properties': {
            'from_cnx_pagemodule_identity': {'$ref': '#standard_definitions/cnx_identity'},
            'to_cnx_pagemodule_identity':   {'$ref': '#standard_definitions/cnx_identity'},
          },
          'required': ['from_cnx_pagemodule_identity', 'to_cnx_pagemodule_identity'],
          'additionalProperties': false,
        },
        'exercise_mapping': {
          'type': 'object',
          'properties': {
            'from_exercise_uuid':         {'$ref': '#standard_definitions/uuid'},
            'to_cnx_pagemodule_identity': {'$ref': '#standard_definitions/cnx_identity'},
          },
          'required': ['from_exercise_uuid', 'to_cnx_pagemodule_identity'],
          'additionalProperties': false,
        },
      },
    }
  end


  def _prepare_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'status': {
          'type': 'string',
          'enum': ['accepted'],
        },
      },
      'required': ['status'],
      'additionalProperties': false,
    }
  end

  def _update_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'update_requests': {
          'type': 'array',
          'items': {'$ref': '#definitions/update_request'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['update_requests'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'update_request': {
          'type': 'object',
          'properties': {
            'request_uuid':      {'$ref': '#standard_definitions/uuid'},
            'preparation_uuid':  {'$ref': '#standard_definitions/uuid'},
          },
          'required': ['request_uuid', 'preparation_uuid'],
          'additionalProperties': false,
        },
      },
    }
  end

  def _update_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'update_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/update_response'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['update_responses'],
      'additionProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'update_response': {
          'type': 'object',
          'properties': {
            'request_uuid': {'$ref': '#standard_definitions/uuid'},
            'update_status': {
              'type': 'string',
              'enum': [
                'preparation_unknown',
                'preparation_obsolete',
                'updated_but_unready',
                'updated_and_ready',
              ],
            },
          },
          'required': ['request_uuid', 'update_status'],
          'additionalProperties': false,
        },
      },
    }
  end

  def _status_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'request_uuid': {'$ref': '#standard_definitions/uuid'},
        'course_uuids': {
          'type': 'array',
          'items': {'$ref': '#standard_definitions/uuid'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['request_uuid', 'course_uuids'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions
    }
  end

  def _status_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'course_statuses': {
          'type': 'array',
          'items': {'$ref': '#definitions/course_status'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['course_statuses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'course_status': {
          'type': 'object',
          'properties': {
            'course_uuid':                        {'$ref': '#standard_definitions/uuid'},
            'course_is_known':                    {'type': 'boolean'},
            'current_ecosystem_preparation_uuid': {'$ref': '#standard_definitions/uuid'},
            'current_ecosystem_status':           {'$ref': '#definitions/ecosystem_status'},
            'next_ecosystem_status':              {'$ref': '#definitions/ecosystem_status'},
          },
          'required': ['course_uuid', 'course_is_known'],
          'additionalProperties': false,
        },
        'ecosystem_status': {
          'type': 'object',
          'properties': {
            'ecosystem_uuid':         {'$ref': '#standard_definitions/uuid'},
            'ecosystem_is_known':     {'type': 'boolean'},
            'ecosystem_is_prepared':  {'type': 'boolean'},
            'precompute_is_complete': {'type': 'boolean'},
          },
          'required': ['ecosystem_uuid', 'ecosystem_is_known', 'ecosystem_is_prepared'],
          'additionalProperties': false,
        },
      },
    }
  end

end
