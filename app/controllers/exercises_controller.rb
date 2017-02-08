class ExercisesController < JsonApiController

  def fetch_assignment_pes
    with_json_apis(input_schema:  _fetch_assignment_pes_request_payload_schema,
                   output_schema: _fetch_assignment_pes_response_payload_schema) do
      request_payload = json_parsed_request_payload
      pe_requests = request_payload.deep_symbolize_keys.fetch(:pe_requests)

      service = Services::FetchAssignmentPes::Service.new
      result = service.process(pe_requests: pe_requests)

      pe_responses = result.fetch(:pe_responses).map do |response|
        response.slice(:assignment_uuid, :exercise_uuids, :assignment_status)
      end

      render json: { pe_responses: pe_responses }.to_json, status: 200
    end
  end

  def fetch_assignment_spes
    with_json_apis(input_schema:  _fetch_assignment_spes_request_payload_schema,
                   output_schema: _fetch_assignment_spes_response_payload_schema) do
      request_payload = json_parsed_request_payload
      spe_requests = request_payload.deep_symbolize_keys.fetch(:spe_requests)

      service = Services::FetchAssignmentSpes::Service.new
      result = service.process(spe_requests: spe_requests)

      spe_responses = result.fetch(:spe_responses).map do |response|
        response.slice(:assignment_uuid, :exercise_uuids, :assignment_status)
      end

      render json: { spe_responses: spe_responses }.to_json, status: 200
    end
  end

  def fetch_practice_worst_areas
    with_json_apis(input_schema:  _fetch_practice_worst_areas_request_payload_schema,
                   output_schema: _fetch_practice_worst_areas_response_payload_schema) do
      request_payload = json_parsed_request_payload
      worst_areas_requests = request_payload.deep_symbolize_keys.fetch(:worst_areas_requests)

      service = Services::FetchPracticeWorstAreasExercises::Service.new
      result = service.process(worst_areas_requests: worst_areas_requests)

      worst_areas_responses = result.fetch(:worst_areas_responses).map do |response|
        response.slice(:student_uuid, :exercise_uuids, :student_status)
      end

      render json: { worst_areas_responses: worst_areas_responses }.to_json, status: 200
    end
  end

  def update_assignment_pes
    with_json_apis(input_schema:  _update_assignment_pes_request_payload_schema,
                   output_schema: _update_assignment_pes_response_payload_schema) do
      request_payload = json_parsed_request_payload
      pe_updates = request_payload.deep_symbolize_keys.fetch(:pe_updates)

      service = Services::UpdateAssignmentPes::Service.new
      result = service.process(pe_updates: pe_updates)

      response_data = result.fetch(:pe_update_responses).map do |response|
        response.slice(:request_uuid, :update_status)
      end

      render json: { pe_update_responses: response_data }.to_json, status: 200
    end
  end

  def update_assignment_spes
    with_json_apis(input_schema:  _update_assignment_spes_request_payload_schema,
                   output_schema: _update_assignment_spes_response_payload_schema) do
      request_payload = json_parsed_request_payload
      spe_updates = request_payload.deep_symbolize_keys.fetch(:spe_updates)

      service = Services::UpdateAssignmentSpes::Service.new
      result = service.process(spe_updates: spe_updates)

      response_data = result.fetch(:spe_update_responses).map do |response|
        response.slice(:request_uuid, :update_status)
      end

      render json: { spe_update_responses: response_data }.to_json, status: 200
    end
  end

  def update_practice_worst_areas
    with_json_apis(input_schema:  _update_practice_worst_areas_request_payload_schema,
                   output_schema: _update_practice_worst_areas_response_payload_schema) do
      request_payload = json_parsed_request_payload
      practice_worst_area_updates = request_payload.deep_symbolize_keys.fetch(:practice_worst_area_updates)

      service = Services::UpdatePracticeWorstAreasExercises::Service.new
      result = service.process(practice_worst_area_updates: practice_worst_area_updates)

      response_data = result.fetch(:practice_worst_area_update_responses).map do |response|
        response.slice(:request_uuid, :update_status)
      end

      render json: { practice_worst_area_update_responses: response_data }.to_json, status: 200
    end
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
          'maxItems': 1000,
        },
      },
      'required': ['pe_requests'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'pe_request': {
          'type': 'object',
          'properties': {
            'assignment_uuid': {'$ref': '#standard_definitions/uuid'},
            'max_num_exercises': {
              'type': 'integer',
              'minimum': 0,
              'maximum': 100,
            },
          },
          'required': ['assignment_uuid', 'max_num_exercises'],
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
          'maxItems': 1000,
        },
      },
      'required': ['pe_responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'pe_response': {
          'type': 'object',
          'properties': {
            'assignment_uuid': {'$ref': '#standard_definitions/uuid'},
            'exercise_uuids': {
              'type': 'array',
              'items': {'$ref': '#standard_definitions/uuid'},
              'minItems': 0,
              'maxItems': 100,
            },
            'assignment_status': {
              'type': 'string',
              'enum': ['assignment_unknown', 'assignment_unready', 'assignment_ready'],
            },
          },
          'required': ['assignment_uuid', 'exercise_uuids', 'assignment_status'],
          'additionalProperties': false,
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
          'maxItems': 1000,
        },
      },
      'required': ['spe_requests'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'spe_request': {
          'type': 'object',
          'properties': {
            'assignment_uuid': {'$ref': '#standard_definitions/uuid'},
            'max_num_exercises': {
              'type': 'integer',
              'minimum': 0,
              'maximum': 100,
            },
          },
          'required': ['assignment_uuid', 'max_num_exercises'],
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
          'maxItems': 1000,
        },
      },
      'required': ['spe_responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'spe_response': {
          'type': 'object',
          'properties': {
            'assignment_uuid': {'$ref': '#standard_definitions/uuid'},
            'exercise_uuids': {
              'type': 'array',
              'items': {'$ref': '#standard_definitions/uuid'},
              'minItems': 0,
              'maxItems': 100,
            },
            'assignment_status': {
              'type': 'string',
              'enum': ['assignment_unknown', 'assignment_unready', 'assignment_ready'],
            },
          },
          'required': ['assignment_uuid', 'exercise_uuids', 'assignment_status'],
          'additionalProperties': false,
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
          'maxItems': 1000,
        },
      },
      'required': ['worst_areas_requests'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'worst_areas_request': {
          'type': 'object',
          'properties': {
            'student_uuid': {'$ref': '#standard_definitions/uuid'},
            'max_num_exercises': {
              'type': 'integer',
              'minimum': 0,
              'maximum': 100,
            },
          },
          'required': ['student_uuid', 'max_num_exercises'],
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
          'maxItems': 1000,
        },
      },
      'required': ['worst_areas_responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'worst_areas_response': {
          'type': 'object',
          'properties': {
            'student_uuid': {'$ref': '#standard_definitions/uuid'},
            'exercise_uuids': {
              'type': 'array',
              'items': {'$ref': '#standard_definitions/uuid'},
              'minItems': 0,
              'maxItems': 100,
            },
            'student_status': {
              'type': 'string',
              'enum': ['student_unknown', 'student_unready', 'student_ready'],
            },
          },
          'required': ['student_uuid', 'exercise_uuids', 'student_status'],
          'additionalProperties': false,
        },
      },
    }
  end

  def _update_assignment_pes_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'pe_requests': {
          'type': 'array',
          'items': {'$ref': '#definitions/pe_update'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['pe_updates'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'pe_update': {
          'type': 'object',
          'properties': {
            'request_uuid': {'$ref': '#standard_definitions/uuid'},
            'assignment_uuid': {'$ref': '#standard_definitions/uuid'},
            'exercise_uuids': {
              'type': 'array',
              'items': {'$ref': '#standard_definitions/uuid'},
              'minItems': 0,
              'maxItems': 100,
            }
          },
          'required': ['request_uuid' , 'assignment_uuid', 'exercise_uuids'],
          'additionalProperties': false,
        },
      },
    }
  end

  def _update_assignment_pes_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'pe_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/pe_update_response'},
          'minItems': 0,
          'maxItems': 1000,
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
              'enum': ['accepted'],
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
        'spe_requests': {
          'type': 'array',
          'items': {'$ref': '#definitions/spe_update'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['spe_updates'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'spe_update': {
          'type': 'object',
          'properties': {
            'request_uuid': {'$ref': '#standard_definitions/uuid'},
            'assignment_uuid': {'$ref': '#standard_definitions/uuid'},
            'exercise_uuids': {
              'type': 'array',
              'items': {'$ref': '#standard_definitions/uuid'},
              'minItems': 0,
              'maxItems': 100,
            }
          },
          'required': ['request_uuid' , 'assignment_uuid', 'exercise_uuids'],
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
        'spe_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/spe_update_response'},
          'minItems': 0,
          'maxItems': 1000,
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
              'enum': ['accepted'],
            }
          },
          'required': ['request_uuid', 'update_status'],
          'additionalProperties': false,
        }
      },
    }
  end


  def _update_practice_worst_areas_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'spe_requests': {
          'type': 'array',
          'items': {'$ref': '#definitions/spe_update'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['spe_updates'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'spe_update': {
          'type': 'object',
          'properties': {
            'request_uuid': {'$ref': '#standard_definitions/uuid'},
            'student_uuid': {'$ref': '#standard_definitions/uuid'},
            'exercise_uuids': {
              'type': 'array',
              'items': {'$ref': '#standard_definitions/uuid'},
              'minItems': 0,
              'maxItems': 100,
            }
          },
          'required': ['request_uuid' , 'student_uuid', 'exercise_uuids'],
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
        'spe_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/spe_update_response'},
          'minItems': 0,
          'maxItems': 1000,
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
              'enum': ['accepted'],
            }
          },
          'required': ['request_uuid', 'update_status'],
          'additionalProperties': false,
        }
      },
    }
  end

end
