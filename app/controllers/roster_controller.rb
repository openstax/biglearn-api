class RosterController < JsonApiController

  def update
    request_payload = json_parsed_request_payload

    # do stuff
  end

  protected

  validate_json_action :update,
    input_schema: {
      '$schema': 'http://json-schema.org/draft-04/schema#',
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
          },
          'required': ['container_uuid', 'parent_container_uuid'],
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
  },
  output_schema: {
    '$schema': 'http://json-schema.org/draft-04/schema#',
    'type': 'object',
    'properties': {
      'updated_course_uuids': {
        'type': 'array',
        'items': {'$ref': '#standard_definitions/uuid'},
        'minItems': 0,
        'maxItems': 1000,
      },
    },
    'required': ['updated_course_uuid'],
    'additionalProperties': false
  }

end
