class Services::CreateCourse::Service < Services::ApplicationService
  MAX_RETRIES = 3
  RETRY_DELAY = 1

  def process(course_uuid:, ecosystem_uuid:, is_real_course:, starts_at:, ends_at:, created_at:)
    retries = 0
    begin
      Course.transaction do
        CourseEvent.append(
          uuid: course_uuid,
          type: :create_course,
          course_uuid: course_uuid,
          sequence_number: 0,
          data: {
            course_uuid: course_uuid,
            sequence_number: 0,
            ecosystem_uuid: ecosystem_uuid,
            is_real_course: is_real_course,
            starts_at: starts_at,
            ends_at: ends_at,
            created_at: created_at
          },
          sequence_number_association_extra_attributes: { initial_ecosystem_uuid: ecosystem_uuid }
        )
      end
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => exception
      raise exception if retries >= MAX_RETRIES

      retries += 1
      log(:warn) { "#{exception.message.split("\n:").first}. Retry ##{retries}..." }
      sleep(RETRY_DELAY)
      retry
    end

    { created_course_uuid: course_uuid }
  end
end
