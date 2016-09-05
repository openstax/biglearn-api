class Services::RecordResponses::Service
  def process(response_data:)
    return [] if response_data.empty?

    start_time     = Time.now
    start_time_str = start_time.utc.iso8601(6)

    values = response_data.map{ |data|
      {
        uuid:            data.fetch(:response_uuid),
        trial_uuid:      data.fetch(:trial_uuid),
        trial_sequence:  data.fetch(:trial_sequence),
        learner_uuid:    data.fetch(:learner_uuid),
        question_uuid:   data.fetch(:question_uuid),
        is_correct:      data.fetch(:is_correct),
        responded_at:    data.fetch(:responded_at),
        created_at:      start_time_str,
        updated_at:      start_time_str,
      }
    }.uniq{|value| value.fetch(:uuid)}.sort_by{|value| value.fetch(:uuid)}

    target_response_uuids = values.map{|value| value.fetch(:uuid)}

    values_str = values.map{ |value|
      %Q{
        ( '#{value.fetch(:uuid)}',
          '#{value.fetch(:trial_uuid)}',
          #{value.fetch(:trial_sequence)},
          '#{value.fetch(:learner_uuid)}',
          '#{value.fetch(:question_uuid)}',
          #{value.fetch(:is_correct) ? 'TRUE' : 'FALSE'},
          TIMESTAMP WITH TIME ZONE '#{value.fetch(:responded_at)}',
          TIMESTAMP WITH TIME ZONE '#{value.fetch(:created_at)}',
          TIMESTAMP WITH TIME ZONE '#{value.fetch(:updated_at)}' )
      }.gsub(/\n\s*/, ' ')
    }.join(',')

    recorded_response_uuids = Response.transaction(isolation: :serializable) do
      sql_inserted_response_uuids = %Q{
        INSERT INTO responses
        (uuid,trial_uuid,trial_sequence,learner_uuid,question_uuid,is_correct,responded_at,created_at,updated_at)
        VALUES #{values_str}
        ON CONFLICT DO NOTHING
        RETURNING uuid
      }.gsub(/\n\s*/, ' ')

      inserted_response_uuids = Response.connection.execute(sql_inserted_response_uuids)
                                        .collect{|hash| hash.fetch('uuid')}

      recorded_response_uuids = Response.distinct
                                        .where{uuid.in target_response_uuids}
                                        .pluck(:uuid).to_a

      recorded_response_uuids
    end

    recorded_response_uuids
  end
end

