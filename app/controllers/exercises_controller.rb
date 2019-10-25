class ExercisesController < JsonApiController

  include ScoutIgnore

  def fetch_assignment_pes
    scout_ignore! 0.99

    respond_with_json_apis_and_service(
      input_schema:  _fetch_assignment_pes_request_payload_schema,
      output_schema: _fetch_assignment_pes_response_payload_schema,
      service: Services::FetchAssignmentPes::Service
    )
  end

  def fetch_assignment_spes
    scout_ignore! 0.99

    respond_with_json_apis_and_service(
      input_schema:  _fetch_assignment_spes_request_payload_schema,
      output_schema: _fetch_assignment_spes_response_payload_schema,
      service: Services::FetchAssignmentSpes::Service
    )
  end

  def fetch_practice_worst_areas
    scout_ignore! 0.99

    respond_with_json_apis_and_service(
      input_schema:  _fetch_practice_worst_areas_request_payload_schema,
      output_schema: _fetch_practice_worst_areas_response_payload_schema,
      service: Services::FetchPracticeWorstAreasExercises::Service
    )
  end

  def update_assignment_pes
    respond_with_json_apis_and_service(
      input_schema:  _update_assignment_pes_request_payload_schema,
      output_schema: _update_assignment_pes_response_payload_schema,
      service: Services::UpdateAssignmentPes::Service
    )
  end

  def update_assignment_spes
    respond_with_json_apis_and_service(
      input_schema:  _update_assignment_spes_request_payload_schema,
      output_schema: _update_assignment_spes_response_payload_schema,
      service: Services::UpdateAssignmentSpes::Service
    )
  end

  def update_practice_worst_areas
    respond_with_json_apis_and_service(
      input_schema:  _update_practice_worst_areas_request_payload_schema,
      output_schema: _update_practice_worst_areas_response_payload_schema,
      service: Services::UpdatePracticeWorstAreasExercises::Service
    )
  end

  protected

  def _fetch_assignment_pes_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'pe_requests': {
          'type': 'array',
          'items': {'$ref': '#definitions/pe_request'},
          'minItems': 0,
          'maxItems': 1000
        },
      },
      'required': ['pe_requests'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'pe_request': {
          'type': 'object',
          'properties': {
            'request_uuid': {'$ref': '#standard_definitions/uuid'},
            'assignment_uuid': {'$ref': '#standard_definitions/uuid'},
            'algorithm_name': {'type': 'string'},
            'max_num_exercises': {
              'type': 'integer',
              'minimum': 0,
              'maximum': 1000
            },
          },
          'required': ['request_uuid', 'assignment_uuid', 'algorithm_name'],
          'additionalProperties': false,
        },
      },
    }
  end

  def _fetch_assignment_pes_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'pe_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/pe_response'},
          'minItems': 0,
          'maxItems': 1000
        },
      },
      'required': ['pe_responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'pe_response': {
          'type': 'object',
          'properties': {
            'request_uuid': {'$ref': '#standard_definitions/uuid'},
            'calculation_uuid': {'$ref': '#standard_definitions/uuid'},
            'ecosystem_matrix_uuid': {'$ref': '#standard_definitions/uuid'},
            'exercise_uuids': {
              'type': 'array',
              'items': {'$ref': '#standard_definitions/uuid'},
              'minItems': 0,
              'maxItems': 1000
            },
            'assignment_status': {
              'type': 'string',
              'enum': ['assignment_unknown', 'assignment_unready', 'assignment_ready']
            },
            'spy_info': {
              'type': 'object',
              'additionalProperties': true
            }
          },
          'required': [
            'request_uuid',
            'calculation_uuid',
            'ecosystem_matrix_uuid',
            'exercise_uuids',
            'assignment_status'
          ],
          'additionalProperties': false
        },
      },
    }
  end

  def _fetch_assignment_spes_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'spe_requests': {
          'type': 'array',
          'items': {'$ref': '#definitions/spe_request'},
          'minItems': 0,
          'maxItems': 1000
        },
      },
      'required': ['spe_requests'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'spe_request': {
          'type': 'object',
          'properties': {
            'request_uuid': {'$ref': '#standard_definitions/uuid'},
            'assignment_uuid': {'$ref': '#standard_definitions/uuid'},
            'algorithm_name': {'type': 'string'},
            'max_num_exercises': {
              'type': 'integer',
              'minimum': 0,
              'maximum': 1000
            },
          },
          'required': ['request_uuid', 'assignment_uuid', 'algorithm_name'],
          'additionalProperties': false,
        },
      },
    }
  end

  def _fetch_assignment_spes_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'spe_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/spe_response'},
          'minItems': 0,
          'maxItems': 1000
        },
      },
      'required': ['spe_responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'spe_response': {
          'type': 'object',
          'properties': {
            'request_uuid': {'$ref': '#standard_definitions/uuid'},
            'calculation_uuid': {'$ref': '#standard_definitions/uuid'},
            'ecosystem_matrix_uuid': {'$ref': '#standard_definitions/uuid'},
            'exercise_uuids': {
              'type': 'array',
              'items': {'$ref': '#standard_definitions/uuid'},
              'minItems': 0,
              'maxItems': 1000
            },
            'assignment_status': {
              'type': 'string',
              'enum': ['assignment_unknown', 'assignment_unready', 'assignment_ready']
            },
            'spy_info': {
              'type': 'object',
              'additionalProperties': true
            }
          },
          'required': [
            'request_uuid',
            'calculation_uuid',
            'ecosystem_matrix_uuid',
            'exercise_uuids',
            'assignment_status'
          ],
          'additionalProperties': false
        },
      },
    }
  end

  def _fetch_practice_worst_areas_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'worst_areas_requests': {
          'type': 'array',
          'items': {'$ref': '#definitions/worst_areas_request'},
          'minItems': 0,
          'maxItems': 1000
        },
      },
      'required': ['worst_areas_requests'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'worst_areas_request': {
          'type': 'object',
          'properties': {
            'request_uuid': {'$ref': '#standard_definitions/uuid'},
            'student_uuid': {'$ref': '#standard_definitions/uuid'},
            'algorithm_name': {'type': 'string'},
            'max_num_exercises': {
              'type': 'integer',
              'minimum': 0,
              'maximum': 1000
            },
          },
          'required': ['request_uuid', 'student_uuid', 'algorithm_name'],
          'additionalProperties': false,
        },
      },
    }
  end

  def _fetch_practice_worst_areas_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'worst_areas_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/worst_areas_response'},
          'minItems': 0,
          'maxItems': 1000
        },
      },
      'required': ['worst_areas_responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'worst_areas_response': {
          'type': 'object',
          'properties': {
            'request_uuid': {'$ref': '#standard_definitions/uuid'},
            'calculation_uuid': {'$ref': '#standard_definitions/uuid'},
            'ecosystem_matrix_uuid': {'$ref': '#standard_definitions/uuid'},
            'exercise_uuids': {
              'type': 'array',
              'items': {'$ref': '#standard_definitions/uuid'},
              'minItems': 0,
              'maxItems': 1000
            },
            'student_status': {
              'type': 'string',
              'enum': ['student_unknown', 'student_unready', 'student_ready']
            },
            'spy_info': {
              'type': 'object',
              'additionalProperties': true
            }
          },
          'required': [
            'request_uuid',
            'calculation_uuid',
            'ecosystem_matrix_uuid',
            'exercise_uuids',
            'student_status'
          ],
          'additionalProperties': false
        },
      },
    }
  end

  def _update_assignment_pes_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'pe_updates': {
          'type': 'array',
          'items': {'$ref': '#definitions/pe_update'},
          'minItems': 0,
          'maxItems': 1000
        },
      },
      'required': ['pe_updates'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'pe_update': {
          'type': 'object',
          'properties': {
            'request_uuid':          {'$ref': '#standard_definitions/uuid'},
            'assignment_uuid':       {'$ref': '#standard_definitions/uuid'},
            'algorithm_name':        {'type': 'string'},
            'calculation_uuid':      {'$ref': '#standard_definitions/uuid'},
            'ecosystem_matrix_uuid': {'$ref': '#standard_definitions/uuid'},
            'exercise_uuids':  {
              'type': 'array',
              'items': {'$ref': '#standard_definitions/uuid'},
              'minItems': 0,
              'maxItems': 1000
            },
            'spy_info': {
              'type': 'object',
              'additionalProperties': true
            }
          },
          'required': [
            'request_uuid',
            'assignment_uuid',
            'algorithm_name',
            'calculation_uuid',
            'ecosystem_matrix_uuid',
            'exercise_uuids'
          ],
          'additionalProperties': false
        },
      },
    }
  end

  def _update_assignment_pes_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'pe_update_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/pe_update_response'},
          'minItems': 0,
          'maxItems': 1000
        },
      },
      'required': ['pe_update_responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'pe_update_response': {
          'type': 'object',
          'properties': {
            'request_uuid': {'$ref': '#standard_definitions/uuid'},
            'update_status': {
              'type': 'string',
              'enum': ['accepted']
            }
          },
          'required': ['request_uuid', 'update_status'],
          'additionalProperties': false,
        }
      },
    }
  end

  def _update_assignment_spes_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'spe_updates': {
          'type': 'array',
          'items': {'$ref': '#definitions/spe_update'},
          'minItems': 0,
          'maxItems': 1000
        },
      },
      'required': ['spe_updates'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'spe_update': {
          'type': 'object',
          'properties': {
            'request_uuid':          {'$ref': '#standard_definitions/uuid'},
            'assignment_uuid':       {'$ref': '#standard_definitions/uuid'},
            'algorithm_name':        {'type': 'string'},
            'calculation_uuid':      {'$ref': '#standard_definitions/uuid'},
            'ecosystem_matrix_uuid': {'$ref': '#standard_definitions/uuid'},
            'exercise_uuids':  {
              'type': 'array',
              'items': {'$ref': '#standard_definitions/uuid'},
              'minItems': 0,
              'maxItems': 1000
            },
            'spy_info': {
              'type': 'object',
              'additionalProperties': true
            }
          },
          'required': [
            'request_uuid' ,
            'assignment_uuid',
            'algorithm_name',
            'calculation_uuid',
            'ecosystem_matrix_uuid',
            'exercise_uuids'
          ],
          'additionalProperties': false,
        },
      },
    }
  end

  def _update_assignment_spes_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'spe_update_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/spe_update_response'},
          'minItems': 0,
          'maxItems': 1000
        },
      },
      'required': ['spe_update_responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'spe_update_response': {
          'type': 'object',
          'properties': {
            'request_uuid': {'$ref': '#standard_definitions/uuid'},
            'update_status': {
              'type': 'string',
              'enum': ['accepted']
            }
          },
          'required': ['request_uuid', 'update_status'],
          'additionalProperties': false
        }
      },
    }
  end


  def _update_practice_worst_areas_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'practice_worst_areas_updates': {
          'type': 'array',
          'items': {'$ref': '#definitions/practice_worst_areas_update'},
          'minItems': 0,
          'maxItems': 1000
        },
      },
      'required': ['practice_worst_areas_updates'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'practice_worst_areas_update': {
          'type': 'object',
          'properties': {
            'request_uuid':          {'$ref': '#standard_definitions/uuid'},
            'student_uuid':          {'$ref': '#standard_definitions/uuid'},
            'algorithm_name':        {'type': 'string'},
            'calculation_uuid':      {'$ref': '#standard_definitions/uuid'},
            'ecosystem_matrix_uuid': {'$ref': '#standard_definitions/uuid'},
            'exercise_uuids': {
              'type': 'array',
              'items': {'$ref': '#standard_definitions/uuid'},
              'minItems': 0,
              'maxItems': 1000
            },
            'spy_info': {
              'type': 'object',
              'additionalProperties': true
            }
          },
          'required': [
            'request_uuid',
            'student_uuid',
            'algorithm_name',
            'calculation_uuid',
            'ecosystem_matrix_uuid',
            'exercise_uuids'
          ],
          'additionalProperties': false,
        },
      },
    }
  end

  def _update_practice_worst_areas_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'practice_worst_areas_update_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/practice_worst_areas_update_response'},
          'minItems': 0,
          'maxItems': 1000
        },
      },
      'required': ['practice_worst_areas_update_responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'practice_worst_areas_update_response': {
          'type': 'object',
          'properties': {
            'request_uuid': {'$ref': '#standard_definitions/uuid'},
            'update_status': {
              'type': 'string',
              'enum': ['accepted']
            }
          },
          'required': ['request_uuid', 'update_status'],
          'additionalProperties': false,
        }
      },
    }
  end

end
