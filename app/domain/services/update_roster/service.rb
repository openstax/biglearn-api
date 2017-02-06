class Services::UpdateRoster::Service
  def process(rosters:)
    course_container_attributes = []
    student_attributes = []
    course_event_attributes = []
    updated_couse_uuids = rosters.map do |roster|
      roster[:course_containers].each do |course_container|
        course_container_attributes << { uuid: course_container[:container_uuid] }
      end

      roster[:students].each do |student|
        student_attributes << { uuid: student[:student_uuid] }
      end

      course_event_attributes << {
        # No appropriate uuid in the request to use here
        uuid: SecureRandom.uuid,
        type: :update_roster,
        course_uuid: roster[:course_uuid],
        sequence_number: roster[:sequence_number],
        data: roster.slice(:course_containers, :students)
      }

      roster[:course_uuid]
    end

    CourseEvent.transaction(isolation: :serializable) do
      CourseContainer.append course_container_attributes
      Student.append         student_attributes
      CourseEvent.append     course_event_attributes
    end

    { updated_course_uuids: updated_couse_uuids }
  end
end
