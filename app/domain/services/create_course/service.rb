class Services::CreateCourse::Service
  def process(course_uuid:, ecosystem_uuid:)

    start_time     = Time.now
    start_time_str = start_time.utc.iso8601(6)

    ecosystem = Ecosystem.find_by uuid: ecosystem_uuid

    fail Errors::AppUnprocessableError.new("Ecosystem #{ecosystem_uuid} does not exist. Course cannot be created.") \
      if ecosystem.nil?

    values_str = %Q{
      '#{course_uuid}',
        '#{ecosystem_uuid}',
        TIMESTAMP WITH TIME ZONE '#{start_time_str}',
        TIMESTAMP WITH TIME ZONE '#{start_time_str}'
    }.gsub(/\n\s*/, ' ')

    select_str = %Q{
      SELECT 1
        FROM courses
        WHERE
          courses.uuid = '#{course_uuid}'
    }.gsub(/\n\s*/, ' ')

    created_course_uuid = Course.transaction(isolation: :serializable) do
      sql_inserted_course = %Q{
        INSERT INTO courses
        (uuid, ecosystem_uuid, created_at, updated_at)
        SELECT #{values_str}
        WHERE NOT EXISTS (#{select_str})
        RETURNING uuid
      }.gsub(/\n\s*/, ' ')

      inserted_courses = Course.connection.execute(sql_inserted_course)

      inserted_courses.collect{|hash| hash.fetch('uuid')}[0] or course_uuid
    end

    {
      created_course_uuid: created_course_uuid
    }
  end
end

