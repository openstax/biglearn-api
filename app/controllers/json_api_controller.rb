require 'json-schema'

class JsonApiController < ApplicationController

  protect_from_forgery #with: :exception

  rescue_from Errors::AppRequestValidationError,  with: :_render_app_request_validation_error
  rescue_from Errors::AppResponseValidationError, with: :_render_app_response_validation_error
  rescue_from Errors::AppUnprocessableError,      with: :_render_app_unprocessable_error

  JSON_SCHEMA='http://json-schema.org/draft-04/schema#'

  def self.validate_json_action(method, input_schema:, output_schema:)
    alias_method "#{method}_without_validation", method
    define_method method do |*args|
      _validate_request(input_schema)
      send "#{method}_without_validation"
      _validate_response(output_schema)
    end
  end

  def with_json_apis(input_schema:, output_schema:, &block)
    _validate_request(input_schema)
    block.call
    _validate_response(output_schema)
  end


  def json_parsed_request_payload
    request.body.rewind
    JSON.parse(request.body.read).deep_symbolize_keys
  rescue StandardError => ex
    fail Errors::AppRequestValidationError.new('could not parse request json payload')
  end


  def _validate_request(input_schema)
    fail Errors::AppRequestHeaderError.new('request must have Content-Type = application/json') \
      unless request.content_type == 'application/json'

    validation_errors = JSON::Validator.fully_validate(
      input_schema,
      json_parsed_request_payload,
      insert_defaults: true,
      validate_schema: true
    )
    fail Errors::AppRequestSchemaError.new('request body failed validation', validation_errors) \
      if validation_errors.any?
  end


  def _validate_response(output_schema)
    fail Errors::AppResponseStatusError.new("invalid response status: #{response.status}") \
      unless response.status == 200

    validation_errors = JSON::Validator.fully_validate(
      output_schema,
      JSON.parse(response.body),
      validate_schema: true
    )

    fail Errors::AppResponseSchemaError.new('response body failed validation', validation_errors) \
      if validation_errors.any?
  rescue StandardError => ex
    fail Errors::AppResponseValidationError.new('could not parse response json payload')
  end


  def _render_app_request_validation_error(exception)
    request_headers = ActionDispatch::Http::Headers::CGI_VARIABLES.inject({}){ |result, key|
      value = request.headers[key]
      result[key] = value unless value.nil? ## TODO: find a way to recover original key
      result
    }
    request.body.rewind
    request_body = request.body.read
    payload = {
      'errors': exception.errors,
      'request': {
        'headers': request_headers,
        'body':    request_body
      }
    }
    render json: payload.to_json, status: 400
  end


  def _render_app_response_validation_error(exception)
    payload = {
     'errors': exception.errors,
      'response': {
        'status':  response.status,
        'headers': response.headers,
        'body':    response.body
      }
    }
    response.status = 500
    response.body   = payload.to_json
  end


  def _render_app_unprocessable_error(exception)
    payload = {
      'errors': exception.errors,
      'exception': exception.inspect,
    }
    render json: payload.to_json, status: 422
  end


  module SchemaDefinitions

    def _standard_definitions
      {
        'uuid': {
          'type': 'string',
          'pattern': '^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-' +
                     '4[a-fA-F0-9]{3}-[a-fA-F0-9]{4}-' +
                     '[a-fA-F0-9]{12}$',
        },
        'number_between_0_and_1': {
          'type': 'number',
          'minimum': 0,
          'maximum': 1,
        },
        'non_negative_integer': {
          'type': 'integer',
          'minumum': 0,
        },
        'datetime': {
          'type': 'string',
          'pattern': '^\d{4}-'                       + ## year
                     '(0[1-9]|1[0-2])-'              + ## month
                     '(0[1-9]|1[0-9]|2[0-9]|3[0-1])' + ## day of month
                     '(T|t)'                         + ## ISO8601 spacer
                     '(0[0-9]|1[0-9]|2[0-3]):'       + ## hour
                     '([0-5][0-9]):'                 + ## minute
                     '([0-5][0-9]|60)'               + ## second
                     '\.\d{6}'                       + ## fraction of second
                     '(Z|z)$'                          ## Zulu timezone
        },
        'receiver_info': {
          'type': 'object',
          'properties': {
            'receiver_uuid': {'$ref': '#/standard_definitions/uuid'},
            'partition_count': {
              'type': 'integer',
              'minumum': 0,
              'maximum': 10000,
            },
            'partition_modulo': {
              'type': 'integer',
              'minumum': 0,
              'maximum': 9999,
            }
          },
          'required': ['receiver_uuid', 'partition_count', 'partition_modulo'],
          'additionalProperties': false,
        },
        'clue_data': {
          'type': 'object',
          'properties': {
            'aggregate': {'$ref': '#/standard_definitions/number_between_0_and_1'},
            'confidence': {
              'type': 'object',
              'properties': {
                'left':                 {'$ref': '#/standard_definitions/number_between_0_and_1'},
                'right':                {'$ref': '#/standard_definitions/number_between_0_and_1'},
                'sample_size':          {'$ref': '#/standard_definitions/non_negative_integer'},
                'unique_learner_count': {'$ref': '#/standard_definitions/non_negative_integer'}
              },
              'required': ['left', 'right', 'sample_size', 'unique_learner_count'],
              'additionalProperties': false
            },
            'interpretation': {
              'type': 'object',
              'properties': {
                'confidence': {
                  'type': 'string',
                  'enum': ['good', 'bad']
                },
                'level': {
                  'type': 'string',
                  'enum': ['high', 'low']
                },
                'threshold': {
                  'type': 'string',
                  'enum': ['above', 'below']
                }
              },
              'required': ['confidence', 'level', 'threshold'],
              'additionalProperties': false
            },
            'pool_id': {'$ref': '#/standard_definitions/uuid'}
          },
          'required': ['aggregate', 'confidence', 'interpretation', 'pool_id'],
          'additionalProperties': false
        },
        'ecosystem_event_type': {
          'type': 'string',
          'enum': EcosystemEvent.types.keys
        },
        'ecosystem_event_data': {
          'type': 'object'
          # TODO: Validate ecosystem_event_data contents
        },
        'course_event_type': {
          'type': 'string',
          'enum': CourseEvent.types.keys
        },
        'course_event_data': {
          'type': 'object'
          # TODO: Validate course_event_data contents
        },
        'exercise_exclusion': {
          'oneOf': [
            {'$ref': '#/standard_definitions/specific_version_exclusion'},
            {'$ref': '#/standard_definitions/any_version_exclusion'},
          ],
        },
        'specific_version_exclusion': {
          'type': 'object',
          'properties': {
            'exercise_uuid': {'$ref': '#/standard_definitions/uuid'},
          },
          'required': ['exercise_uuid'],
          'additionalProperties': false,
        },
        'any_version_exclusion': {
          'type': 'object',
          'properties': {
            'exercise_group_uuid': {'$ref': '#/standard_definitions/uuid'},
          },
          'required': ['exercise_group_uuid'],
          'additionalProperties': false,
        }
      }
    end

    def _generic_error_schema
      {
        '$schema': JSON_SCHEMA,
        'type': 'object',
        'properties': {
          'errors': {
            'type': 'array',
            'items': {
              'type': 'string',
            },
            'minItems': 1,
          },
        },
        'required': ['errors'],
        'additionalProperties': false
      }
    end

  end

  # make methods available both on instance and class
  include SchemaDefinitions
  extend SchemaDefinitions

end
