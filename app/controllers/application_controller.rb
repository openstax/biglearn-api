require 'json-schema'


class AppError < StandardError;

  attr_reader :nested_exception
  attr_reader :local_errors
  attr_reader :location

  def initialize(*local_errors)
    @local_errors = Array(local_errors).flatten
    @nested_exception = $!
    @location = caller[1]
  end

  def errors
    nested_errors =
      if @nested_exception.nil?
        []
      elsif @nested_exception.respond_to? :errors
        @nested_exception.errors
      else
        Array(@nested_exception.message)
      end
    local_errors + nested_errors
  end

  def raw_message_lines
    nested_message_lines =
      if @nested_exception.nil?
        []
      elsif @nested_exception.respond_to? :raw_message_lines
        @nested_exception.raw_message_lines
      else
        "#{@nested_exception.class.name} [#{@nested_exception.backtrace.first}]: #{@nested_exception.message}"
      end
    ["#{self.class.name} [#{self.location}]: #{self.local_errors}"] + Array(nested_message_lines)
  end

  def inspect
    raw_message_lines.each_with_index.collect{ |line, idx|
      ' '*2*idx + line
    }
  end

  def backtrace
    if @nested_exception
      @nested_exception.backtrace
    else
      super
    end
  end

end


class AppRequestValidationError < AppError; end
class AppRequestHeaderError < AppRequestValidationError; end
class AppRequestSchemaError < AppRequestValidationError; end

class AppResponseValidationError < AppError; end
class AppResponseStatusError < AppResponseValidationError; end
class AppResponseSchemaError < AppResponseValidationError; end

class AppUnprocessableError < AppError; end


class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery #with: :exception

  rescue_from AppRequestValidationError,  with: :_render_app_request_validation_error
  rescue_from AppResponseValidationError, with: :_render_app_response_validation_error
  rescue_from AppUnprocessableError,      with: :_render_app_unprocessable_error


  def with_json_apis(input_schema:, output_schema:, &block)
    _validate_request(input_schema)
    block.call
    _validate_response(output_schema)
  end


  def json_parsed_request_payload
    request.body.rewind
    JSON.parse(request.body.read)
  rescue StandardError => ex
    fail AppRequestValidationError.new('could not parse request json payload')
  end


  def _validate_request(input_schema)
    fail AppRequestHeaderError.new('request must have Content-Type = application/json') \
      unless request.content_type == 'application/json'

    validation_errors = JSON::Validator.fully_validate(
      input_schema,
      json_parsed_request_payload,
      insert_defaults: true,
      validate_schema: true
    )

    fail AppRequestSchemaError.new('request body failed validation', validation_errors) \
      if validation_errors.any?
  end


  def _validate_response(output_schema)
    fail AppResponseStatusError.new("invalid response status: #{response.status}") \
      unless response.status == 200

    validation_errors = JSON::Validator.fully_validate(
      output_schema,
      JSON.parse(response.body),
      validate_schema: true
    )

    fail AppResponseSchemaError.new('response body failed validation', validation_errors) \
      if validation_errors.any?
  rescue StandardError => ex
    fail AppResponseValidationError.new('could not parse response json payload')
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


  def _standard_definitions
    {
      'uuid': {
        'type': 'string',
        'pattern': '^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-' +
                   '4[a-fA-F0-9]{3}-[a-fA-F0-9]{4}-'  +
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
    }
  end


  def _generic_error_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

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
      'additionalProperties': false,
    }
  end

end
