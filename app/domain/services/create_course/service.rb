class Services::CreateCourse::Service
  def process(course_uuid:, ecosystem_uuid:)
    return nil if course_uuid.nil? or ecosystem_uuid.nil?

    start_time     = Time.now
    start_time_str = start_time.utc.iso8601(6)

    ecosystem = Ecosystem.find_by uuid: ecosystem_uuid

    return nil if ecosystem.nil?

    values_str = %Q{
      ( '#{course_uuid}',
        '#{ecosystem_uuid}',
        TIMESTAMP WITH TIME ZONE '#{start_time_str}',
        TIMESTAMP WITH TIME ZONE '#{start_time_str}' )
    }.gsub(/\n\s*/, ' ')

    created_course_uuid = Course.transaction(isolation: :serializable) do
      sql_inserted_course = %Q{
        INSERT INTO courses
        (uuid,ecosystem_uuid,created_at,updated_at)
        VALUES #{values_str}
        ON CONFLICT DO NOTHING
        RETURNING uuid
      }.gsub(/\n\s*/, ' ')

      inserted_course = Course.connection.execute(sql_inserted_course)

      inserted_course.collect{|hash| hash.fetch('uuid')}[0]
    end

    {
      created_course_uuid: created_course_uuid
    }
  end
end

