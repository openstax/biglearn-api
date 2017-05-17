class ExerciseExclusionsController < JsonApiController

  def update_course
    respond_with_json_apis_and_service(
      input_schema:  _update_course_request_payload_schema,
      output_schema: _update_course_response_payload_schema,
      service: Services::UpdateCourseExerciseExclusions::Service
    )
  end

  def update_global
    respond_with_json_apis_and_service(
      input_schema:  _update_global_request_payload_schema,
      output_schema: _update_global_response_payload_schema,
      service: Services::UpdateGlobalExerciseExclusions::Service
    )
  end

  protected

  def _update_course_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'request_uuid':    {'$ref': '#/standard_definitions/uuid'},
        'course_uuid':     {'$ref': '#/standard_definitions/uuid'},
        'sequence_number': {'$ref': '#/standard_definitions/non_negative_integer'},
        'exclusions': {
          'type': 'array',
          'items': {'$ref': '#/standard_definitions/exercise_exclusion'},
          'minItems': 0,
          'maxItems': 10000
        },
        'updated_at': {'$ref': '#/standard_definitions/datetime'}
      },
      'required': ['request_uuid', 'course_uuid', 'sequence_number', 'exclusions', 'updated_at'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions
    }
  end

  def _update_course_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'status': {
          'emum': ['success'],
        },
      },
      'required': ['status'],
      'additionalProperties': false,
    }
  end

  def _update_global_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'request_uuid':    {'$ref': '#/standard_definitions/uuid'},
        'course_uuid':     {'$ref': '#/standard_definitions/uuid'},
        'sequence_number': {'$ref': '#/standard_definitions/non_negative_integer'},
        'exclusions': {
          'type': 'array',
          'items': {'$ref': '#/standard_definitions/exercise_exclusion'},
          'minItems': 0,
          'maxItems': 10000,
        },
        'updated_at': {'$ref': '#/standard_definitions/datetime'}
      },
      'required': ['request_uuid', 'course_uuid', 'sequence_number', 'exclusions', 'updated_at'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions
    }
  end

  def _update_global_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'status': {
          'emum': ['success'],
        },
      },
      'required': ['status'],
      'additionalProperties': false,
    }
  end

end
