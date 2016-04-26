require 'json-schema'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def with_json_apis(input_schema:, output_schema_map:, &block)
    if request.format != :json
      payload = { 'errors': [ 'request must have Content-Type = application/json' ] }
      render json: payload.to_json, status: 400
      return
    end

    payload_params_key = request.params['controller'].singularize

    errors = JSON::Validator.fully_validate(
      input_schema,
      request.params[payload_params_key],
      insert_defaults: true,
      validate_schema: true
    )
    if errors.any?
      payload = { 'errors': errors }
      render json: payload.to_json, status: 400
      return
    end

    block.call

    unless output_schema_map.has_key? response.status
      response.status = 500
      return
    end

    errors = JSON::Validator.fully_validate(
      output_schema_map[response.status],
      JSON.parse(response.body),
      validate_schema: true
    )
    response.status = 500 if errors.any?
  end
end
