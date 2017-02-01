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

end
