class Services::CreateCourse::Service
  def process(course_uuid:, ecosystem_uuid:)

    unless Ecosystem.find_by uuid: ecosystem_uuid
      fail Errors::AppUnprocessableError.new("Ecosystem #{ecosystem_uuid} does not exist. Course cannot be created.")
    end

    course = Course.new(
      :uuid           => course_uuid,
      :ecosystem_uuid => ecosystem_uuid
    )

    Course.transaction(isolation: :serializable) do
      Course.import [course], on_duplicate_key_ignore: true
    end

    { created_course_uuid: course_uuid }
  end
end
