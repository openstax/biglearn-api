class Services::CourseEcosystemStatus::Service
  def process(request_uuid:, course_uuids:)
    create_courses_by_course_uuid = CourseEvent.create_course
                                               .where(uuid: course_uuids)
                                               .index_by(&:uuid)
    sorted_ecosystem_preparations = CourseEvent.prepare_course_ecosystem
                                               .where(course_uuid: course_uuids)
                                               .order(:sequence_number)
    sorted_ecosystem_preparations_by_course_uuid = \
      sorted_ecosystem_preparations.group_by(&:course_uuid)
    sorted_ecosystem_preparations_by_preparation_uuid = \
      sorted_ecosystem_preparations.group_by(&:uuid)
    sorted_ecosystem_updates_by_course_uuid = CourseEvent.update_course_ecosystem
                                                         .where(course_uuid: course_uuids)
                                                         .order(:sequence_number)
                                                         .group_by(&:course_uuid)

    course_is_known_by_course_uuid = {}
    current_ecosystems_uuids_by_course_uuid = {}
    next_ecosystem_uuids_by_course_uuid = {}
    current_preparation_uuids_by_course_uuid = {}
    next_preparation_uuids_by_course_uuid = {}
    course_uuids.each do |course_uuid|
      create_course = create_courses_by_course_uuid[course_uuid]
      course_is_known_by_course_uuid[course_uuid] = !create_course.nil?

      current_ecosystem_update = (sorted_ecosystem_updates_by_course_uuid[course_uuid] || []).last

      if current_ecosystem_update.present?
        prep_uuid = current_ecosystem_update.data.symbolize_keys[:preparation_uuid]
        current_ecosystem_preparation = \
          (sorted_ecosystem_preparations_by_preparation_uuid[prep_uuid] || []).last
        current_update_sequence_number = current_ecosystem_update.sequence_number
      else
        current_update_sequence_number = 0
      end

      if current_ecosystem_preparation.present?
        current_preparation_uuids_by_course_uuid[course_uuid] = current_ecosystem_preparation.uuid

        current_ecosystem_uuid = \
          current_ecosystem_preparation.data.symbolize_keys[:next_ecosystem_uuid]
      else
        current_ecosystem_uuid = create_course.data.symbolize_keys[:ecosystem_uuid] \
          if create_course.present?
      end

      current_ecosystems_uuids_by_course_uuid[course_uuid] = current_ecosystem_uuid

      next_ecosystem_preparation = \
        (sorted_ecosystem_preparations_by_course_uuid[course_uuid] || []).last

      if next_ecosystem_preparation.present? &&
         next_ecosystem_preparation.sequence_number > current_update_sequence_number
        next_preparation_uuids_by_course_uuid[course_uuid] = next_ecosystem_preparation.uuid

        next_ecosystem_uuids_by_course_uuid[course_uuid] = \
          next_ecosystem_preparation.data.symbolize_keys[:next_ecosystem_uuid]
      end
    end

    all_ecosystem_uuids = current_ecosystems_uuids_by_course_uuid.values +
                          next_ecosystem_uuids_by_course_uuid.values
    known_ecosystem_uuids = Set.new(
      EcosystemEvent.create_ecosystem.where(uuid: all_ecosystem_uuids).pluck(:uuid)
    )

    all_preparation_uuids = current_preparation_uuids_by_course_uuid.values +
                            next_preparation_uuids_by_course_uuid.values
    precomputed_preparation_uuids = Set.new(
      EcosystemPreparationReady.where(uuid: all_preparation_uuids).pluck(:uuid)
    )

    course_statuses = course_uuids.map do |course_uuid|
      course_is_known = course_is_known_by_course_uuid[course_uuid]

      current_ecosystem_uuid = current_ecosystems_uuids_by_course_uuid[course_uuid]
      current_ecosystem_is_known = known_ecosystem_uuids.include? current_ecosystem_uuid
      current_preparation_uuid = current_preparation_uuids_by_course_uuid[course_uuid]
      current_ecosystem_is_prepared = current_preparation_uuid.present?
      current_precompute_is_complete = \
        precomputed_preparation_uuids.include? current_preparation_uuid

      current_ecosystem_status = {
        ecosystem_uuid: current_ecosystem_uuid,
        ecosystem_is_known: current_ecosystem_is_known,
        ecosystem_is_prepared: current_ecosystem_is_prepared,
        precompute_is_complete: current_precompute_is_complete
      }

      next_ecosystem_uuid = next_ecosystem_uuids_by_course_uuid[course_uuid]
      next_ecosystem_is_known = known_ecosystem_uuids.include? next_ecosystem_uuid
      next_preparation_uuid = next_preparation_uuids_by_course_uuid[course_uuid]
      next_ecosystem_is_prepared = next_preparation_uuid.present?
      next_precompute_is_complete = precomputed_preparation_uuids.include? next_preparation_uuid

      next_ecosystem_status = {
        ecosystem_uuid: next_ecosystem_uuid,
        ecosystem_is_known: next_ecosystem_is_known,
        ecosystem_is_prepared: next_ecosystem_is_prepared,
        precompute_is_complete: next_precompute_is_complete
      }

      {
        course_uuid: course_uuid,
        course_is_known: course_is_known,
        current_ecosystem_preparation_uuid: next_preparation_uuid,
        current_ecosystem_status: current_ecosystem_status,
        next_ecosystem_status: next_ecosystem_status
      }
    end

    { course_statuses: course_statuses }
  end
end
