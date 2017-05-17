class RostersController < JsonApiController

  def update
    respond_with_json_apis_and_service(
      input_schema:  _update_request_payload_schema,
      output_schema: _update_response_payload_schema,
      service: Services::UpdateRosters::Service
    )
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
            'request_uuid':    {'$ref': '#standard_definitions/uuid'},
            'course_uuid':     {'$ref': '#standard_definitions/uuid'},
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
            }
          },
          'required': [
            'request_uuid',
            'course_uuid',
            'sequence_number',
            'course_containers',
            'students'
          ],
          'additionalProperties': false,
        },
        'course_container': {
          'type': 'object',
          'properties': {
            'container_uuid':        {'$ref': '#standard_definitions/uuid'},
            'parent_container_uuid': {'$ref': '#standard_definitions/uuid'},
            'created_at':            {'$ref': '#/standard_definitions/datetime'},
            'archived_at':           {'$ref': '#/standard_definitions/datetime'}
          },
          'required': ['container_uuid', 'parent_container_uuid', 'created_at'],
          'additionalProperties': false,
        },
        'student': {
          'type': 'object',
          'properties': {
            'student_uuid':                    {'$ref': '#standard_definitions/uuid'},
            'container_uuid':                  {'$ref': '#standard_definitions/uuid'},
            'enrolled_at':                     {'$ref': '#/standard_definitions/datetime'},
            'last_course_container_change_at': {'$ref': '#/standard_definitions/datetime'},
            'dropped_at':                      {'$ref': '#/standard_definitions/datetime'}
          },
          'required': [
            'student_uuid',
            'container_uuid',
            'enrolled_at',
            'last_course_container_change_at'
          ],
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
        'updated_rosters': {
          'type': 'array',
          'items': {
            'type': 'object',
            'properties': {
              'request_uuid': {'$ref': '#standard_definitions/uuid'},
              'updated_course_uuid': {'$ref': '#standard_definitions/uuid'}
            },
            'required': ['request_uuid', 'updated_course_uuid'],
            'additionalProperties': false
          },
          'minItems': 0,
          'maxItems': 100,
        },
      },
      'required': ['updated_rosters'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions
    }
  end

end
