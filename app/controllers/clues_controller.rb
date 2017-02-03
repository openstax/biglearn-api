class CluesController < JsonApiController

  def student
    with_json_apis(input_schema:  _student_request_payload_schema,
                   output_schema: _student_response_payload_schema) do
      request_payload = json_parsed_request_payload
      student_clue_requests_data = request_payload.deep_symbolize_keys.fetch(:student_clue_requests)

      service = Services::FetchStudentClues::Service.new
      result = service.process(student_clue_requests: student_clue_requests_data)

      response_data = result.fetch(:student_clue_responses).map do |response|
        response.slice(:request_uuid, :clue_data, :clue_status)
      end

      render json: { student_clue_responses: response_data }.to_json, status: 200
    end
  end

  def teacher
    with_json_apis(input_schema:  _teacher_request_payload_schema,
                   output_schema: _teacher_response_payload_schema) do
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

  protected

  def _student_request_payload_schema
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
          },
          'required': ['request_uuid', 'student_uuid', 'book_container_uuid'],
          'additionalProperties': false,
        },
      },
    }
  end

  def _student_response_payload_schema
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

  def _teacher_request_payload_schema
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
          },
          'required': ['request_uuid', 'course_container_uuid', 'book_container_uuid'],
          'additionalProperties': false,
        },
      },
    }
  end

  def _teacher_response_payload_schema
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

end
