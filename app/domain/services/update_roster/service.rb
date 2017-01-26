class Services::UpdateRoster::Service
  def process(rosters:)
    ActiveRecord::Base.transaction(isolation: :serializable) do
      create_students(rosters: rosters)

      create_course_containers(rosters: rosters)

      create_course_rosters(rosters: rosters)
    end

    updated_couse_uuids = rosters.map { |roster| roster[:course_uuid] }

    { updated_course_uuids: updated_couse_uuids }
  end

  protected

  def create_students(rosters:)
    students = rosters.flat_map do |roster|
      roster[:students].map do |student|
        Student.new(
          uuid: student[:student_uuid],
          course_uuid: roster[:course_uuid]
        )
      end
    end

    Student.import students, on_duplicate_key_ignore: true
  end

  def create_course_containers(rosters:)
    course_containers = rosters.flat_map do |roster|
      roster[:course_containers].map do |container|
        CourseContainer.new(
          uuid: container[:container_uuid],
          course_uuid: roster[:course_uuid]
        )
      end
    end

    CourseContainer.import course_containers, on_duplicate_key_ignore: true
  end

  def create_course_rosters(rosters:)
    course_rosters = rosters.map do |roster|
      CourseRoster.new(
        uuid: SecureRandom.uuid,
        course_uuid: roster[:course_uuid],
        sequence_number: roster[:sequence_number]
      )
    end

    result = CourseRoster.import course_rosters, on_duplicate_key_ignore: true
    imported_course_rosters = (course_rosters - result.failed_instances)
    course_rosters_by_course_uuid = imported_course_rosters.index_by(&:course_uuid)
    course_uuids = course_rosters_by_course_uuid.keys
    imported_rosters = rosters.select{ |roster| course_uuids.include?(roster[:course_uuid]) }

    all_roster_containers = []
    all_roster_students = []

    imported_rosters.each do |roster|
      course_roster = course_rosters_by_course_uuid[roster[:course_uuid]]

      roster_containers = roster[:course_containers].map do |container|
        RosterContainer.new(
          uuid: SecureRandom.uuid,
          course_roster: course_roster,
          container_uuid: container[:container_uuid],
          parent_roster_container_uuid: container[:parent_container_uuid]
        )
      end
      roster_containers_by_container_uuid = roster_containers.index_by(&:container_uuid)
      all_roster_containers += roster_containers

      all_roster_students += roster[:students].map do |student|
        roster_container = roster_containers_by_container_uuid[student[:container_uuid]]

        RosterStudent.new(
          uuid: SecureRandom.uuid,
          course_roster: course_roster,
          roster_container: roster_container,
          student_uuid: student[:student_uuid]
        )
      end
    end

    RosterContainer.import all_roster_containers

    RosterStudent.import all_roster_students
  end
end
