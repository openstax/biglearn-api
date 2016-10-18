class Services::Roster::Update


  attr_reader :rosters

  def initialize(payload)
    @rosters = payload['rosters'].map do | roster |
      RosterUpdate.new(roster)
    end
  end

  def process!
    Course.transaction(isolation: :serializable) do
      rosters.each(&:process)
    end
  end

  def response
    { 'updated_course_uuids' => rosters.map{ |r| r.course.uuid } }
  end

  class RosterUpdate
    attr_reader :course, :roster
    def initialize(roster)
      @roster = roster
      @course = Course.where(uuid: roster['course_uuid']).first!
    end

    def process
      students = Set.new course.students.pluck(:student_uuid)
      containers = Set.new course.containers.pluck(:container_uuid)
      sync_students(students, containers, roster['students'])
      sync_containers(containers, roster['course_containers'])
    end

    def sync_students(students, containers, update)
      update.each do |student|
        ensure_container(containers, student['container_uuid'])
        unless students.include? student['student_uuid']
          CourseStudent.create! student
        end
        # remove the student from the list, so we can find students to remove
        students.delete student['student_uuid']
      end

      # remove any students that remain
      course.students.where(student_uuid: students.to_a).delete_all if students.any?
    end

    def sync_containers(containers, update)

      update.each do |container|
        ensure_container(containers, container['container_uuid'])
        containers.delete container['container_uuid']
      end

      # Likewise remove invalid containers.
      # Q: is this what should happen if the container still has students?
      containers.each do |container_uuid|
        if course.containers.find(container_uuid).students.any?
          raise "Container #{container_uuid} is to be removed but it still has students present!"
        end
      end
      course.containers.where(container_uuid: containers.to_a).delete_all if containers.any?
    end


    def ensure_container(containers, container_uuid)
      unless containers.include? container_uuid
        course.containers.create(container_uuid: container_uuid)
        containers.add(container_uuid)
      end
    end

  end
end
