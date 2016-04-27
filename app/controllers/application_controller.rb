require 'json-schema'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  def with_json_apis(input_schema:, output_schema_map:, &block)
    request_errors = _validate_request(input_schema)
    if request_errors.any?
      _render_request_error_response(request_errors)
      return
    end

    block.call

    response_errors = _validate_response(output_schema_map)
    if response_errors.any?
      _modify_response(response_errors)
      return
    end
  end


  def json_parsed_request_payload
    payload_params_key = request.params['controller'].singularize
    request.params[payload_params_key]
  end


  def _validate_request(input_schema)
    errors =
      if request.content_type != 'application/json'
        [ 'request must have Content-Type = application/json' ]
      else
        validation_errors = JSON::Validator.fully_validate(
          input_schema,
          json_parsed_request_payload,
          insert_defaults: true,
          validate_schema: true
        )
        if validation_errors.any?
          ['request body failed validation'] + validation_errors
        else
          []
        end
      end
    errors
  end


  def _render_request_error_response(errors)
    request_headers = ActionDispatch::Http::Headers::CGI_VARIABLES.inject({}){ |result, key|
      value = request.headers[key]
      result[key] = value unless value.nil? ## TODO: find a way to recover original key
      result
    }
    request.body.rewind
    request_body = request.body.read
    payload = {
      'errors': errors,
      'request': {
        'headers': request_headers,
        'body':    request_body
      }
    }
    render json: payload.to_json, status: 400
  end


  def _validate_response(output_schema_map)
    errors =
      if !output_schema_map.has_key? response.status
        [ 'response status invalid' ]
      else
        validation_errors = JSON::Validator.fully_validate(
          output_schema_map[response.status],
          JSON.parse(response.body),
          validate_schema: true
        )
        if validation_errors.any?
          ['response body failed validation'] + validation_errors
        else
          []
        end
      end
    errors
  end


  def _modify_response(errors)
    payload = {
     'errors': errors,
      'response': {
        'status':  response.status,
        'headers': response.headers,
        'body':    response.body
      }
    }
    response.status = 500
    response.body = payload.to_json
  end


  def _standard_definitions
    {
      'uuid': {
        'type': 'string',
        'pattern': '^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-' +
                   '[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-'  +
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
