class CoursesController < JsonApiController

  def create
    respond_with_json_apis_and_service(
      input_schema:  _create_request_payload_schema,
      output_schema: _create_response_payload_schema,
      service: Services::CreateCourse::Service
    )
  end

  def update_active_dates
    respond_with_json_apis_and_service(
      input_schema:  _update_active_dates_request_payload_schema,
      output_schema: _update_active_dates_response_payload_schema,
      service: Services::UpdateCourseActiveDates::Service
    )
  end

  def fetch_metadatas
    respond_with_json_apis_and_service(
      output_schema: _fetch_metadatas_response_payload_schema,
      service: Services::FetchCourseMetadatas::Service
    )
  end

  def fetch_events
    respond_with_json_apis_and_service(
      input_schema:  _fetch_events_request_payload_schema,
      output_schema: _fetch_events_response_payload_schema,
      service: Services::FetchCourseEvents::Service
    )
  end

  protected

  def _create_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'course_uuid':    {'$ref': '#/standard_definitions/uuid'},
        'ecosystem_uuid': {'$ref': '#/standard_definitions/uuid'},
        'is_real_course': {'type': 'boolean'},
        'starts_at':      {'$ref': '#/standard_definitions/datetime'},
        'ends_at':        {'$ref': '#/standard_definitions/datetime'},
        'created_at':     {'$ref': '#/standard_definitions/datetime'}
      },
      'required': [
        'course_uuid',
        'ecosystem_uuid',
        'is_real_course',
        'starts_at',
        'ends_at',
        'created_at'
      ],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions
    }
  end

  def _create_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'created_course_uuid': {'$ref': '#/standard_definitions/uuid'},
      },
      'required': ['created_course_uuid'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions
    }
  end

  def _update_active_dates_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'request_uuid':    {'$ref': '#standard_definitions/uuid'},
        'course_uuid':     {'$ref': '#/standard_definitions/uuid'},
        'sequence_number': {'$ref': '#/standard_definitions/non_negative_integer'},
        'starts_at':       {'$ref': '#/standard_definitions/datetime'},
        'ends_at':         {'$ref': '#/standard_definitions/datetime'},
        'updated_at':      {'$ref': '#/standard_definitions/datetime'}
      },
      'required': [
        'request_uuid',
        'course_uuid',
        'sequence_number',
        'starts_at',
        'ends_at',
        'updated_at'
      ],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions
    }
  end

  def _update_active_dates_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'updated_course_uuid': {'$ref': '#/standard_definitions/uuid'},
      },
      'required': ['updated_course_uuid'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions
    }
  end

  def _fetch_metadatas_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'course_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/course_metadata'},
          'minItems': 0,
          'maxItems': 10000
        },
      },
      'required': ['course_responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'course_metadata': {
          'type': 'object',
          'properties': {
            'uuid': {'$ref': '#standard_definitions/uuid'},
            'initial_ecosystem_uuid': {'$ref': '#standard_definitions/uuid'}
          },
          'required': ['uuid', 'initial_ecosystem_uuid'],
          'additionalProperties': false
        }
      }
    }
  end

  def _fetch_events_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'course_event_requests': {
          'type': 'array',
          'items': {'$ref': '#definitions/course_event_request'},
          'minItems': 0,
          'maxItems': 100
        }
      },
      'required': ['course_event_requests'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'course_event_request': {
          'type': 'object',
          'properties': {
            'request_uuid': {'$ref': '#standard_definitions/uuid'},
            'event_types': {
              'type': 'array',
              'items': {'$ref': '#standard_definitions/course_event_type'},
              'minItems': 1
            },
            'course_uuid': {'$ref': '#standard_definitions/uuid'},
            'sequence_number_offset': {'$ref': '#standard_definitions/non_negative_integer'},
            'max_num_events': {
              'type': 'integer',
              'minimum': 1,
              'maximum': 100
            }
          },
          'required': ['request_uuid', 'course_uuid', 'sequence_number_offset', 'max_num_events'],
          'additionalProperties': false
        }
      }
    }
  end

  def _fetch_events_response_payload_schema
    {
      '$schema': JSON_SCHEMA,
      'type': 'object',
      'properties': {
        'course_event_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/course_event_response'},
          'minItems': 0,
          'maxItems': 100
        },
      },
      'required': ['course_event_responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'course_event_response': {
          'type': 'object',
          'properties': {
            'request_uuid': {'$ref': '#standard_definitions/uuid'},
            'course_uuid':  {'$ref': '#standard_definitions/uuid'},
            'events': {
              'type': 'array',
              'items': {
                'type': 'object',
                'properties': {
                  'sequence_number': {'$ref': '#standard_definitions/non_negative_integer'},
                  'event_uuid':      {'$ref': '#standard_definitions/uuid'},
                  'event_type':      {'$ref': '#standard_definitions/course_event_type'},
                  'event_data':      {'$ref': '#standard_definitions/course_event_data'}
                },
                'required': ['sequence_number', 'event_uuid', 'event_type', 'event_data'],
                'additionalProperties': false
              },
              'minItems': 0,
              'maxItems': 1000
            },
            'is_gap': {'type': 'boolean'},
            'is_end': {'type': 'boolean'}
          },
          'required': ['request_uuid', 'course_uuid', 'events', 'is_gap', 'is_end'],
          'additionalProperties': false
        }
      }
    }
  end

end
