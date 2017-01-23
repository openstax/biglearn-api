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

      response_payload = { status: 'accepted' }

      render json: response_payload.to_json, status: 200
    end
  end

  protected

  def _prepare_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'perparation_uuid':    {'$ref': '#standard_definitions/uuid'},
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

end
