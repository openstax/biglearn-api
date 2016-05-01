class JsonApiController < ApplicationController

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
