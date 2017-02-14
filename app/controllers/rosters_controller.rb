class RostersController < JsonApiController

  def update
    with_json_apis(input_schema:  _update_request_payload_schema,
                   output_schema: _update_response_payload_schema) do
      roster_data = json_parsed_request_payload.fetch(:rosters)

      service = Services::UpdateRoster::Service.new
      result = service.process(rosters: roster_data)

      response_payload = { updated_course_uuids: roster_data.map { |roster| roster[:course_uuid] } }
      render json: response_payload.to_json, status: 200
    end
  end

  protected

  def _update_request_payload_schema
    {
      '$schema': JSON_SCHEMA,
      'type': 'object',
      'properties': {
        'rosters': {
          'type': 'array',
          'items': {'$ref': '#definitions/roster'},
          'minItems': 0,
          'maxItems': 100,
        }
      },
      'required': ['rosters'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'roster': {
          'type': 'object',
          'properties': {
            'course_uuid': {'$ref': '#standard_definitions/uuid'},
            'sequence_number': {'$ref': '#standard_definitions/non_negative_integer'},
            'course_containers': {
              'type': 'array',
              'items': {'$ref': '#definitions/course_container'},
              'minItems': 1,
              'maxItems': 100,
            },
            'students': {
              'type': 'array',
              'items': {'$ref': '#definitions/student'},
              'minItems': 0,
              'maxItems': 1000,
            },
          },
          'required': ['course_uuid', 'sequence_number', 'course_containers', 'students'],
          'additionalProperties': false,
        },
        'course_container': {
          'type': 'object',
          'properties': {
            'container_uuid': {'$ref': '#standard_definitions/uuid'},
            'parent_container_uuid': {'$ref': '#standard_definitions/uuid'},
            'is_archived': {'type': 'boolean'}
          },
          'required': ['container_uuid', 'parent_container_uuid', 'is_archived'],
          'additionalProperties': false,
        },
        'student': {
          'type': 'object',
          'properties': {
            'student_uuid': {'$ref': '#standard_definitions/uuid'},
            'container_uuid': {'$ref': '#standard_definitions/uuid'},
          },
          'required': ['student_uuid', 'container_uuid'],
          'additionalProperties': false,
        }
      }
    }
  end

  def _update_response_payload_schema
    {
      '$schema': JSON_SCHEMA,
      'type': 'object',
      'properties': {
        'updated_course_uuids': {
          'type': 'array',
          'items': {'$ref': '#standard_definitions/uuid'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['updated_course_uuids'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions
    }
  end

end
