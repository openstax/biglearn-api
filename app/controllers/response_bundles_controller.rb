class ResponseBundlesController < JsonApiController

  def fetch
    with_json_apis(input_schema:  _fetch_request_payload_schema,
                   output_schema: _fetch_response_payload_schema) do
      request_payload = json_parsed_request_payload

      max_bundles_to_return          = request_payload.fetch('max_bundles_to_return')
      request_confirmed_bundle_uuids = request_payload.fetch('confirmed_bundle_uuids')
      receiver_uuid                  = request_payload.fetch('receiver_info').fetch('receiver_uuid')
      partition_count                = request_payload.fetch('receiver_info').fetch('partition_count')
      partition_modulo               = request_payload.fetch('receiver_info').fetch('partition_modulo')

      response_data, bundle_uuids, response_confirmed_bundle_uuids = _fetch_response_bundles(
        max_bundles_to_return:  max_bundles_to_return,
        confirmed_bundle_uuids: request_confirmed_bundle_uuids,
        receiver_uuid:          receiver_uuid,
        partition_count:        partition_count,
        partition_modulo:       partition_modulo,
      )

      response_payload = {
        confirmed_bundle_uuids: response_confirmed_bundle_uuids,
        bundle_uuids:           bundle_uuids,
        responses:              response_data,
      }

      render json: response_payload.to_json, status: 200
    end
  end


  def _fetch_response_bundles(max_bundles_to_return:,
                              confirmed_bundle_uuids:,
                              receiver_uuid:,
                              partition_count:,
                              partition_modulo:)
    response_data, bundle_uuids, response_confirmed_bundle_uuids = ResponseBundle.transaction(isolation: :serializable) do
      response_confirmed_bundle_uuids = _create_confirmations(
        receiver_uuid:          receiver_uuid,
        confirmed_bundle_uuids: confirmed_bundle_uuids
      )

      bundle_uuids, response_data = _get_bundles(
        max_bundles_to_return: max_bundles_to_return,
        receiver_uuid:         receiver_uuid,
        partition_count:       partition_count,
        partition_modulo:      partition_modulo
      )

      _create_receipts(
        bundle_uuids:  bundle_uuids,
        receiver_uuid: receiver_uuid
      )

      [response_data, bundle_uuids, response_confirmed_bundle_uuids]
    end

    [response_data, bundle_uuids, response_confirmed_bundle_uuids]
  end


  def _create_confirmations(receiver_uuid:, confirmed_bundle_uuids:)
    return [] if confirmed_bundle_uuids.empty?

    ##
    ## Collect only the uuids of ResponseBundles that:
    ##   - already exist
    ##   - are sent
    ##   - are closed
    ##

    uuid_str = confirmed_bundle_uuids.map{|uuid| "'#{uuid}'"}
                                     .join(',')

    sql_valid_confirmed_bundle_uuids = %Q{
      SELECT uuid FROM response_bundles
      INNER JOIN response_bundle_receipts ON response_bundles.uuid = response_bundle_receipts.response_bundle_uuid
      WHERE response_bundles.is_open IS FALSE
      AND uuid IN (#{uuid_str})
    }.gsub(/\n\s*/, ' ')

    valid_confirmed_bundle_uuids =
      ResponseBundle.connection.execute(sql_valid_confirmed_bundle_uuids)
                    .map{|hash| hash['uuid']}

    return [] if valid_confirmed_bundle_uuids.empty?

    ##
    ## Create the SQL value string.
    ##

    start_time     = Time.now
    start_time_str = start_time.utc.iso8601(6)

    values = valid_confirmed_bundle_uuids.map{ |bundle_uuid|
      {
        response_bundle_uuid: bundle_uuid,
        receiver_uuid:        receiver_uuid,
        created_at:           start_time_str,
        updated_at:           start_time_str,
      }
    }.sort_by{|value| value[:response_bundle_uuid]}

    target_response_bundle_uuids = values.map{|value| value[:response_bundle_uuid]}

    values_str = values.map{ |value|
      %Q{ ( '#{value[:response_bundle_uuid]}',
            '#{value[:receiver_uuid]}',
            TIMESTAMP WITH TIME ZONE '#{value[:created_at]}',
            TIMESTAMP WITH TIME ZONE '#{value[:updated_at]}' )
      }.gsub(/\n\s*/, ' ')
    }.join(',')

    ##
    ## Perform an UPSERT, ignoring conflicts.
    ##

    sql_newly_confirmed_bundle_uuids = %Q{
      INSERT INTO response_bundle_confirmations
        (response_bundle_uuid,receiver_uuid,created_at,updated_at)
      VALUES #{values_str}
      ON CONFLICT DO NOTHING
      RETURNING response_bundle_uuid
    }.gsub(/\n\s*/, ' ')

    newly_confirmed_bundle_uuids =
      ResponseBundleConfirmation.connection.execute(sql_newly_confirmed_bundle_uuids)
                                .collect{|hash| hash['response_bundle_uuid']}

    ##
    ## Collect now-confirmed ResponseBundle uuids.
    ##

    confirmed_bundle_uuids = ResponseBundleConfirmation.distinct
                                                       .where{response_bundle_uuid.in target_response_bundle_uuids}
                                                       .pluck(:response_bundle_uuid).to_a

    confirmed_bundle_uuids
  end


  def _get_bundles(max_bundles_to_return:,
                   receiver_uuid:,
                   partition_count:,
                   partition_modulo:)

    ##
    ## Find all bundle uuids that have not yet been confirmed
    ## by this receiver that also belong to the partition.
    ##

    sql_bundle_uuids = %Q{
      SELECT uuid FROM (
        SELECT * FROM response_bundles rb
        WHERE NOT EXISTS (
          SELECT response_bundle_uuid FROM response_bundle_confirmations rbc
          WHERE rbc.receiver_uuid = '#{receiver_uuid}'
          AND rb.uuid = rbc.response_bundle_uuid
        )
      ) AS unconfirmed
      WHERE unconfirmed.partition_value % #{partition_count} = #{partition_modulo}
      ORDER BY unconfirmed.is_open ASC, unconfirmed.created_at ASC
      LIMIT #{max_bundles_to_return}
    }.gsub(/\n\s*/, ' ')

    bundle_uuids =
      ResponseBundle.connection.execute(sql_bundle_uuids)
                    .map{|hash| hash.fetch('uuid')}

    ##
    ## Get the response data for the partition bundles.
    ##

    response_uuids = ResponseBundleEntry.where{response_bundle_uuid.in bundle_uuids}
                                        .map(&:response_uuid)

    response_data = Response.where{uuid.in response_uuids}
                            .map{ |response|
                              {
                                response_uuid:  response.uuid,
                                trial_uuid:     response.trial_uuid,
                                trial_sequence: response.trial_sequence,
                                learner_uuid:   response.learner_uuid,
                                question_uuid:  response.question_uuid,
                                is_correct:     response.is_correct,
                                responded_at:   response.responded_at,
                              }
                            }

    [ bundle_uuids, response_data ]
  end


  def _create_receipts(bundle_uuids:, receiver_uuid:)
    closed_bundle_uuids = ResponseBundle.where{uuid.in bundle_uuids}
                                        .where{is_open == false}
                                        .map(&:uuid)

    return if closed_bundle_uuids.none?

    ##
    ## Create the SQL value string.
    ##

    start_time     = Time.now
    start_time_str = start_time.utc.iso8601(6)

    values = closed_bundle_uuids.map{ |bundle_uuid|
      {
        response_bundle_uuid: bundle_uuid,
        receiver_uuid:        receiver_uuid,
        created_at:           start_time_str,
        updated_at:           start_time_str,
      }
    }.sort_by{|value| value[:response_bundle_uuid]}

    values_str = values.map{ |value|
      %Q{
        ( '#{value[:response_bundle_uuid]}',
          '#{value[:receiver_uuid]}',
          TIMESTAMP WITH TIME ZONE '#{value[:created_at]}',
          TIMESTAMP WITH TIME ZONE '#{value[:updated_at]}' )
      }.gsub(/\n\s*/, ' ')
    }.join(',')

    ##
    ## Perform an UPSERT, ignoring conflicts.
    ##

    sql_upsert_bundle_receipts = %Q{
      INSERT INTO response_bundle_receipts
        (response_bundle_uuid,receiver_uuid,created_at,updated_at)
      VALUES #{values_str}
      ON CONFLICT DO NOTHING
      RETURNING response_bundle_uuid
    }
    ResponseBundleReceipt.connection.execute(sql_upsert_bundle_receipts)
                         .collect{|hash| hash['response_bundle_uuid']}
  end


  def _fetch_request_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'max_bundles_to_return': {
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000,
        },
        'confirmed_bundle_uuids': {
          'type': 'array',
          'items': {'$ref': '#standard_definitions/uuid'},
          'minItems': 0,
          'maxItems': 5000,
        },
        'receiver_info': {'$ref': '#standard_definitions/receiver_info'},
      },
      'required': [
        'max_bundles_to_return',
        'confirmed_bundle_uuids',
        'receiver_info',
      ],
      'additionalProperties': false,

      'standard_definitions': _standard_definitions,
    }
  end


  def _fetch_response_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'confirmed_bundle_uuids': {
          'type': 'array',
          'items': {'$ref': '#standard_definitions/uuid'},
          'minItems': 0,
          'maxItems': 5000,
        },
        'bundle_uuids': {
          'type': 'array',
          'items': {'$ref': '#standard_definitions/uuid'},
          'minItems': 0,
          'maxItems': 1000,
        },
        'responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/response'},
          'minItems': 0,
        },
      },
      'required': ['confirmed_bundle_uuids', 'bundle_uuids', 'responses'],
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


end
