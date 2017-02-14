class CoursesController < JsonApiController

  def create
    with_json_apis(input_schema:  _create_request_payload_schema,
                   output_schema: _create_response_payload_schema) do
      request_payload = json_parsed_request_payload

      course_uuid = request_payload.fetch(:course_uuid)
      ecosystem_uuid = request_payload.fetch(:ecosystem_uuid)

      service = Services::CreateCourse::Service.new
      result = service.process(
        course_uuid: course_uuid,
        ecosystem_uuid: ecosystem_uuid
      )

      response_payload = { created_course_uuid: result.fetch(:created_course_uuid) }

      render json: response_payload.to_json, status: 200
    end
  end

  def fetch_metadatas
    with_json_apis(output_schema: _fetch_metadatas_response_payload_schema) do

      service = Services::FetchCourseMetadatas::Service.new
      result = service.process()

      response_payload = { course_responses: result.fetch(:course_responses) }
      render json: response_payload.to_json, status: 200
    end
  end

  def _create_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'course_uuid':    {'$ref': '#/standard_definitions/uuid'},
        'ecosystem_uuid': {'$ref': '#/standard_definitions/uuid'},
      },
      'required': ['course_uuid', 'ecosystem_uuid'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,
    }
  end


  def _create_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'created_course_uuid': {'$ref': '#/standard_definitions/uuid'},
      },
      'required': ['created_course_uuid'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,
    }
  end

  def _fetch_metadatas_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'course_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/course_metadata'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['course_responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'course_metadata': {
          'type': 'object',
          'properties': {
            'uuid': {'$ref': '#standard_definitions/uuid'},
            'initial_ecosystem_uuid': {'$ref': '#standard_definitions/uuid'}
          },
          'required': ['uuid'],
          'additionalProperties': false
        }
      }
    }
  end

end
