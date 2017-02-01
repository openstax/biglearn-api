class AssignmentsController < JsonApiController

  def create_update
    with_json_apis(input_schema:  _create_update_request_payload_schema,
                   output_schema: _create_update_response_payload_schema) do
      request_payload = json_parsed_request_payload
      assignment_data = request_payload.deep_symbolize_keys.fetch(:assignments)

      service = Services::CreateUpdateAssignments::Service.new
      result = service.process(assignments: assignment_data)

      response_payload = { updated_assignments: result.fetch(:updated_assignments) }

      render json: response_payload.to_json, status: 200
    end
  end

  protected

  def _create_update_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'assignments': {
          'type': 'array',
          'items': {'$ref': '#definitions/assignment'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['assignments'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'assignment': {
          'type': 'object',
          'properties': {
            'assignment_uuid': {'$ref': '#standard_definitions/uuid'},
            'sequence_number': {'$ref': '#standard_definitions/non_negative_integer'},
            'is_deleted':      {'type': 'boolean'},
            'ecosystem_uuid':  {'$ref': '#standard_definitions/uuid'},
            'student_uuid':    {'$ref': '#standard_definitions/uuid'},
            'assignment_type': {  ## NOTE: This should match the usage when creating ecosystem pools
              'type': 'string',
              'minLength': 1,
              'maxLength': 100,
            },
            'exclusion_info': {  ## NOTE: optional
              'type': 'object',
              'properties': {
                'opens_at': {'$ref': '#standard_definitions/datetime'}, ## NOTE: optional
                'due_at':   {'$ref': '#standard_definitions/datetime'},
              },
              'required': ['due_at'],
              'additionalProperties': false,
            },
            'assigned_book_container_uuids': {
              'type': 'array',
              'items': {'$ref': '#standard_definitions/uuid'},
              'minItems': 0,
              'maxItems': 500,
            },
            'goal_num_tutor_assigned_spes': {'$ref': '#standard_definitions/non_negative_integer'},
            'spes_are_assigned': {'type': 'boolean'},
            'goal_num_tutor_assigned_pes': {'$ref': '#standard_definitions/non_negative_integer'},
            'pes_are_assigned': {'type': 'boolean'},
            'assigned_exercises': {
              'type': 'array',
              'items': {'$ref': '#definitions/trial'},
              'minItems': 0,
              'maxItems': 1000,
            },
          },
          'required': [
            'assignment_uuid',
            'sequence_number',
            'student_uuid',
            'ecosystem_uuid',
            'assignment_type',
            'assigned_book_container_uuids',
            'goal_num_tutor_assigned_spes',
            'goal_num_tutor_assigned_pes',
            'assigned_exercises',
          ],
          'additionalProperties': false,
        },
        'trial': {
          'type': 'object',
          'properties': {
            'trial_uuid':    {'$ref': '#standard_definitions/uuid'},
            'exercise_uuid': {'$ref': '#standard_definitions/uuid'},
            'is_spe': {'type': 'boolean'},
            'is_pe':  {'type': 'boolean'},
          },
          'required': ['trial_uuid', 'exercise_uuid', 'is_spe', 'is_pe'],
          'additionalProperties': false,
        },
      },
    }
  end


  def _create_update_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'updated_assignments': {
          'type': 'array',
          'items': {
            'type': 'object',
            'properties': {
              'assignment_uuid': {'$ref': '#standard_definitions/uuid'},
              'sequence_number': {'$ref': '#standard_definitions/non_negative_integer'},
            },
            'required': ['assignment_uuid', 'sequence_number'],
            'additionalProperties': false,
          },
        },
      },
      'required': ['updated_assignments'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions
    }
  end

end
