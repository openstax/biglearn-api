class CluesController < JsonApiController

  def fetch_student
    with_json_apis(input_schema:  _fetch_student_request_payload_schema,
                   output_schema: _fetch_student_response_payload_schema) do
      student_clue_requests_data = json_parsed_request_payload.fetch(:student_clue_requests)

      service = Services::FetchStudentClues::Service.new
      result = service.process(student_clue_requests: student_clue_requests_data)

      response_data = result.fetch(:student_clue_responses).map do |response|
        response.slice(:request_uuid, :clue_data, :clue_status)
      end

      render json: { student_clue_responses: response_data }.to_json, status: 200
    end
  end

  def fetch_teacher
    with_json_apis(input_schema:  _fetch_teacher_request_payload_schema,
                   output_schema: _fetch_teacher_response_payload_schema) do
      request_payload = json_parsed_request_payload
      teacher_clue_requests_data = request_payload.deep_symbolize_keys.fetch(:teacher_clue_requests)

      service = Services::FetchTeacherClues::Service.new
      result = service.process(teacher_clue_requests: teacher_clue_requests_data)

      response_data = result.fetch(:teacher_clue_responses).map do |response|
        response.slice(:request_uuid, :clue_data, :clue_status)
      end

      render json: { teacher_clue_responses: response_data }.to_json, status: 200
    end
  end

  def update_student
    with_json_apis(input_schema:  _update_student_request_payload_schema,
                   output_schema: _update_student_response_payload_schema) do
      request_payload = json_parsed_request_payload
      student_clue_updates = request_payload.deep_symbolize_keys.fetch(:student_clue_updates)

      service = Services::UpdateStudentClues::Service.new
      result = service.process(student_clue_updates: student_clue_updates)

      response_data = result.fetch(:student_clue_update_responses).map do |response|
        response.slice(:request_uuid, :update_status)
      end

      render json: { student_clue_update_responses: response_data }.to_json, status: 200
    end
  end

  def update_teacher
    with_json_apis(input_schema:  _update_teacher_request_payload_schema,
                   output_schema: _update_teacher_response_payload_schema) do
      request_payload = json_parsed_request_payload
      teacher_clue_updates = request_payload.deep_symbolize_keys.fetch(:teacher_clue_updates)

      service = Services::UpdateTeacherClues::Service.new
      result = service.process(teacher_clue_updates: teacher_clue_updates)

      response_data = result.fetch(:teacher_clue_update_responses).map do |response|
        response.slice(:request_uuid, :update_status)
      end

      render json: { teacher_clue_update_responses: response_data }.to_json, status: 200
    end
  end

  protected

  def _fetch_student_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'student_clue_requests': {
          'type': 'array',
          'items': {'$ref': '#definitions/student_clue_request'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['student_clue_requests'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'student_clue_request': {
          'type': 'object',
          'properties': {
            'request_uuid':        {'$ref': '#standard_definitions/uuid'},
            'student_uuid':        {'$ref': '#standard_definitions/uuid'},  ## Course-specific Student uuid
            'book_container_uuid': {'$ref': '#standard_definitions/uuid'},  ## Ecosystem-specific uuid (not CNX uuid)
            'algorithm_name': {'type': 'string'}
          },
          'required': ['request_uuid', 'student_uuid', 'book_container_uuid', 'algorithm_name'],
          'additionalProperties': false,
        },
      },
    }
  end

  def _fetch_student_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'student_clue_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/student_clue_response'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['student_clue_responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'student_clue_response': {
          'type': 'object',
          'properties': {
            'request_uuid': {'$ref': '#standard_definitions/uuid'},
            'clue_data':    {'$ref': '#standard_definitions/clue_data'},
            'clue_status': {
              'type': 'string',
              'enum': ['student_unknown', 'book_container_unknown', 'clue_unready', 'clue_ready'],
            },
          },
          'required': ['request_uuid', 'clue_data', 'clue_status'],
          'additionalProperties': false,
        },
      },
    }
  end

  def _fetch_teacher_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'teacher_clue_requests': {
          'type': 'array',
          'items': {'$ref': '#definitions/teacher_clue_request'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['teacher_clue_requests'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'teacher_clue_request': {
          'type': 'object',
          'properties': {
            'request_uuid':          {'$ref': '#standard_definitions/uuid'},
            'course_container_uuid': {'$ref': '#standard_definitions/uuid'},  ## Course-specific period, etc., container uuid
            'book_container_uuid':   {'$ref': '#standard_definitions/uuid'},  ## Ecosystem-specific uuid (not CNX uuid)
            'algorithm_name': {'type': 'string'}
          },
          'required': [
            'request_uuid',
            'course_container_uuid',
            'book_container_uuid',
            'algorithm_name'
          ],
          'additionalProperties': false,
        },
      },
    }
  end

  def _fetch_teacher_response_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'teacher_clue_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/teacher_clue_response'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['teacher_clue_responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'teacher_clue_response': {
          'type': 'object',
          'properties': {
            'request_uuid': {'$ref': '#standard_definitions/uuid'},
            'clue_data':    {'$ref': '#standard_definitions/clue_data'},
            'clue_status': {
              'type': 'string',
              'enum': [
                'course_container_unknown', 'book_container_unknown', 'clue_unready', 'clue_ready'
              ],
            },
          },
          'required': ['request_uuid', 'clue_data', 'clue_status'],
          'additionalProperties': false,
        },
      },
    }
  end

  def _update_student_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'student_clue_updates': {
          'type': 'array',
          'items': {'$ref': '#definitions/student_clue_update'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['student_clue_updates'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'student_clue_update': {
          'type': 'object',
          'properties': {
            'request_uuid':        {'$ref': '#standard_definitions/uuid'},
            'student_uuid':        {'$ref': '#standard_definitions/uuid'},
            'book_container_uuid': {'$ref': '#standard_definitions/uuid'},
            'algorithm_name':      {'type': 'string'},
            'clue_data':           {'$ref': '#standard_definitions/clue_data'}
          },
          'required': [
            'request_uuid',
            'student_uuid',
            'book_container_uuid',
            'algorithm_name',
            'clue_data'
          ],
          'additionalProperties': false,
        },
      },
    }
  end

  def _update_student_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'student_clue_update_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/student_clue_update_response'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['student_clue_update_responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'student_clue_update_response': {
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
        },
      },
    }
  end

  def _update_teacher_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'teacher_clue_updates': {
          'type': 'array',
          'items': {'$ref': '#definitions/teacher_clue_update'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['teacher_clue_updates'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'teacher_clue_update': {
          'type': 'object',
          'properties': {
            'request_uuid':          {'$ref': '#standard_definitions/uuid'},
            'course_container_uuid': {'$ref': '#standard_definitions/uuid'},
            'book_container_uuid':   {'$ref': '#standard_definitions/uuid'},
            'algorithm_name':        {'type': 'string'},
            'clue_data':             {'$ref': '#standard_definitions/clue_data'}
          },
          'required': [
            'request_uuid',
            'course_container_uuid',
            'book_container_uuid',
            'algorithm_name',
            'clue_data'
          ],
          'additionalProperties': false,
        },
      },
    }
  end

  def _update_teacher_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'teacher_clue_update_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/teacher_clue_update_response'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['teacher_clue_update_responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'teacher_clue_update_response': {
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
        },
      },
    }
  end

end
