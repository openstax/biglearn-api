class Services::FetchTeacherClues::Service
  def process(teacher_clue_requests:)
    responses = teacher_clue_requests.map do |request|
      {
        request_uuid: request[:request_uuid],
        clue_data: {},
        clue_status: 'course_container_unknown'
      }
    end

    { teacher_clue_responses: responses }
  end
end
