class Services::FetchStudentClues::Service
  def process(student_clue_requests:)
    responses = student_clue_requests.map do |request|
      {
        request_uuid: request[:request_uuid],
        clue_data: {},
        clue_status: 'student_unknown'
      }
    end

    { student_clue_responses: responses }
  end
end
