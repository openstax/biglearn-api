class Services::CourseEcosystemStatus::Service
  def process(request_uuid:, course_uuids:)
    course_statuses = course_uuids.map do |course_uuid|
      course = Course.find_by(uuid: course_uuid)
      course_is_known = !course.nil?
      current_ecosystem_preparation_uuid = course&.next_ecosystem_preparation&.uuid

      current_ecosystem = course&.current_ecosystem
      current_ecosystem_uuid = current_ecosystem&.uuid
      # We require an ecosystem when the course is created, so if the course exists the eco is known
      current_ecosystem_is_known = !course.nil?
      # We only allow updates through preparations, so all ecosystems but the first are prepared
      current_ecosystem_is_prepared = current_ecosystem != course&.ecosystem
      # TODO: Some way of setting this to true
      current_precompute_is_complete = false

      current_ecosystem_status = {
        ecosystem_uuid: current_ecosystem_uuid,
        ecosystem_is_known: current_ecosystem_is_known,
        ecosystem_is_prepared: current_ecosystem_is_prepared,
        precompute_is_complete: current_precompute_is_complete
      }

      next_ecosystem = course&.next_ecosystem
      next_ecosystem_uuid = next_ecosystem&.uuid
      next_ecosystem_is_known = next_ecosystem.present?
      # We only allow updates through preparations, so presence indicates preparation
      next_ecosystem_is_prepared = next_ecosystem.present?
      # TODO: Some way of setting this to true
      next_precompute_is_complete = false

      next_ecosystem_status = {
        ecosystem_uuid: next_ecosystem_uuid,
        ecosystem_is_known: next_ecosystem_is_known,
        ecosystem_is_prepared: next_ecosystem_is_prepared,
        precompute_is_complete: next_precompute_is_complete
      }

      {
        course_uuid: course_uuid,
        course_is_known: course_is_known,
        current_ecosystem_preparation_uuid: current_ecosystem_preparation_uuid,
        current_ecosystem_status: current_ecosystem_status,
        next_ecosystem_status: next_ecosystem_status
      }
    end

    { course_statuses: course_statuses }
  end
end
