class ResponsesController < JsonApiController

  def record
    with_json_apis(input_schema:  _record_request_payload_schema,
                   output_schema: _record_response_payload_schema) do
      request_payload = json_parsed_request_payload
      response_data = request_payload['responses'].map(&:deep_symbolize_keys)

      recorded_response_uuids = _record_responses(response_data: response_data)

      render json: {'recorded_response_uuids': recorded_response_uuids}.to_json, status: 200
    end
  end


  def _record_responses(response_data:)
    start_time     = Time.now
    start_time_str = start_time.utc.iso8601(6)

    return [] if response_data.empty?

    values = response_data.map{ |data|
      {
        response_uuid:  data[:response_uuid],
        trial_uuid:     data[:trial_uuid],
        trial_sequence: data[:trial_sequence],
        learner_uuid:   data[:learner_uuid],
        question_uuid:  data[:question_uuid],
        is_correct:     data[:is_correct],
        responded_at:   data[:responded_at],
        created_at:     start_time_str,
        updated_at:     start_time_str,
      }
    }.uniq{|value| value[:response_uuid]}.sort_by{|value| value[:response_uuid]}

    target_response_uuids = values.map{|value| value[:response_uuid]}

    values_str = values.map{ |value|
      "(" +
      [ %Q('#{value[:response_uuid]}'),
        %Q('#{value[:trial_uuid]}'),
        %Q(#{value[:trial_sequence]}),
        %Q('#{value[:learner_uuid]}'),
        %Q('#{value[:question_uuid]}'),
        (value[:is_correct] ? 'TRUE' : 'FALSE'),
        %Q(TIMESTAMP WITH TIME ZONE '#{value[:responded_at]}'),
        %Q(TIMESTAMP WITH TIME ZONE '#{value[:created_at]}'),
        %Q(TIMESTAMP WITH TIME ZONE '#{value[:updated_at]}'),
        ].join(',') +
      ")"
    }.join(',')

    recorded_response_uuids = Response.transaction(isolation: :serializable) do
      inserted_response_uuids = Response.connection.execute(
        [
          %Q!INSERT INTO responses!,
          %Q!(response_uuid,trial_uuid,trial_sequence,learner_uuid,question_uuid,is_correct,responded_at,created_at,updated_at)!,
          %Q!VALUES #{values_str}!,
          %Q!ON CONFLICT DO NOTHING!,
          %Q!RETURNING response_uuid!,
        ].join(' ')
      ).collect{|hash| hash[:response_uuid]}

      recorded_response_uuids = Response.distinct
                                        .where{response_uuid.in target_response_uuids}
                                        .pluck(:response_uuid).to_a

      recorded_response_uuids
    end

    recorded_response_uuids
  end


  def _record_request_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/response'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['responses'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,

      'definitions': {
        'response': {
          'type': 'object',
          'properties': {
            'response_uuid':  {'$ref': '#standard_definitions/uuid'},
            'trial_uuid':     {'$ref': '#standard_definitions/uuid'},
            'trial_sequence': {'$ref': '#standard_definitions/non_negative_integer'},
            'learner_uuid':   {'$ref': '#standard_definitions/uuid'},
            'question_uuid':  {'$ref': '#standard_definitions/uuid'},
            'is_correct':     {'type': 'boolean'},
            'responded_at':   {'$ref': '#standard_definitions/datetime'},
          },
          'required': [
            'response_uuid',
            'trial_uuid',
            'trial_sequence',
            'learner_uuid',
            'question_uuid',
            'is_correct',
            'responded_at',
          ],
          'additionalProperties': false,
        },
      },
    }
  end


  def _record_response_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'recorded_response_uuids': {
          'type': 'array',
          'items': {'$ref': '#standard_definitions/uuid'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['recorded_response_uuids'],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,
    }
  end

end
