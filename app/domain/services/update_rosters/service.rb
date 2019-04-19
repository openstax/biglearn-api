class Services::UpdateRosters::Service < Services::ApplicationService
  def process(rosters:)
    course_container_attributes = []
    student_attributes = []
    course_event_attributes = []
    updated_rosters = rosters.map do |roster|
      roster.fetch(:course_containers).each do |course_container|
        course_container_attributes << { uuid: course_container.fetch(:container_uuid) }
      end

      roster.fetch(:students).each do |student|
        student_attributes << { uuid: student.fetch(:student_uuid) }
      end

      course_event_attributes << {
        # No appropriate uuid in the request to use here
        uuid: roster.fetch(:request_uuid),
        type: :update_roster,
        course_uuid: roster.fetch(:course_uuid),
        sequence_number: roster.fetch(:sequence_number),
        data: roster.slice(
          :request_uuid,
          :course_uuid,
          :sequence_number,
          :course_containers,
          :students
        )
      }

      roster.slice(:request_uuid).merge(updated_course_uuid: roster.fetch(:course_uuid))
    end

    CourseEvent.transaction do
      CourseEvent.append     course_event_attributes
      CourseContainer.append course_container_attributes
      Student.append         student_attributes
    end

    { updated_rosters: updated_rosters }
  end
end
