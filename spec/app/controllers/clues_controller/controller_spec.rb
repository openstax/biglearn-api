require 'rails_helper'

RSpec.describe CluesController, type: :request do
  let(:given_request_1_uuid)            { SecureRandom.uuid }
  let(:given_book_container_1_uuid)     { SecureRandom.uuid }
  let(:given_request_2_uuid)            { SecureRandom.uuid }
  let(:given_book_container_2_uuid)     { SecureRandom.uuid }

  let(:target_response)                 { target_result }

  context '#student' do
    let(:given_student_1_uuid)          { SecureRandom.uuid }
    let(:given_student_2_uuid)          { SecureRandom.uuid }

    let(:given_clue_requests)           do
      [
        {
          request_uuid: given_request_1_uuid,
          student_uuid: given_student_1_uuid,
          book_container_uuid: given_book_container_1_uuid
        },
        {
          request_uuid: given_request_2_uuid,
          student_uuid: given_student_2_uuid,
          book_container_uuid: given_book_container_2_uuid
        }
      ]
    end

    let(:request_payload)               { { student_clue_requests: given_clue_requests } }

    let(:target_result)                 do
      {
        student_clue_responses: [
          {
            request_uuid: given_request_1_uuid,
            clue_data: {
              aggregate: 0.8,
              confidence: {
                left: 0.7,
                right: 0.9,
                sample_size: 10,
                unique_learner_count: 1
              },
              interpretation: {
                confidence: 'good',
                level: 'high',
                threshold: 'above'
              },
              pool_id: given_book_container_1_uuid
            },
            clue_status: 'clue_ready'
          },
          {
            request_uuid: given_request_2_uuid,
            clue_data: {
              aggregate: 0.5,
              confidence: {
                left: 0,
                right: 1,
                sample_size: 0,
                unique_learner_count: 0
              },
              interpretation: {
                confidence: 'bad',
                level: 'low',
                threshold: 'below'
              },
              pool_id: given_book_container_2_uuid
            },
            clue_status: 'student_unknown'
          }
        ]
      }
    end

    let(:service_double)                do
      object_double(Services::FetchStudentClues::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
      end
    end

    before(:each)                       do
      allow(Services::FetchStudentClues::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = fetch_student_clues(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = fetch_student_clues(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the FetchStudentClues service is called with the correct course data" do
        response_status, response_body = fetch_student_clues(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_response" do
        response_status, response_body = fetch_student_clues(request_payload: request_payload)
        expect(response_body).to eq(target_response.deep_stringify_keys)
      end
    end
  end

  context '#teacher' do
    let(:given_course_container_1_uuid) { SecureRandom.uuid }
    let(:given_course_container_2_uuid) { SecureRandom.uuid }

    let(:given_clue_requests)           do
      [
        {
          request_uuid: given_request_1_uuid,
          course_container_uuid: given_course_container_1_uuid,
          book_container_uuid: given_book_container_1_uuid
        },
        {
          request_uuid: given_request_2_uuid,
          course_container_uuid: given_course_container_2_uuid,
          book_container_uuid: given_book_container_2_uuid
        }
      ]
    end

    let(:request_payload)               { { teacher_clue_requests: given_clue_requests } }

    let(:target_result)                 do
      {
        teacher_clue_responses: [
          {
            request_uuid: given_request_1_uuid,
            clue_data: {
              aggregate: 0.8,
              confidence: {
                left: 0.7,
                right: 0.9,
                sample_size: 50,
                unique_learner_count: 5
              },
              interpretation: {
                confidence: 'good',
                level: 'high',
                threshold: 'above'
              },
              pool_id: given_book_container_1_uuid
            },
            clue_status: 'clue_ready'
          },
          {
            request_uuid: given_request_2_uuid,
            clue_data: {
              aggregate: 0.5,
              confidence: {
                left: 0,
                right: 1,
                sample_size: 0,
                unique_learner_count: 0
              },
              interpretation: {
                confidence: 'bad',
                level: 'low',
                threshold: 'below'
              },
              pool_id: given_book_container_2_uuid
            },
            clue_status: 'course_container_unknown'
          }
        ]
      }
    end

    let(:service_double)                do
      object_double(Services::FetchTeacherClues::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
      end
    end

    before(:each)                       do
      allow(Services::FetchTeacherClues::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = fetch_teacher_clues(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = fetch_teacher_clues(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the FetchStudentClues service is called with the correct course data" do
        response_status, response_body = fetch_teacher_clues(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_response" do
        response_status, response_body = fetch_teacher_clues(request_payload: request_payload)
        expect(response_body).to eq(target_response.deep_stringify_keys)
      end
    end
  end

  protected

  def fetch_student_clues(request_payload:)
    make_post_request(
      route: '/fetch_student_clues',
      headers: { 'Content-Type' => 'application/json' },
      body:  request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end

  def fetch_teacher_clues(request_payload:)
    make_post_request(
      route: '/fetch_teacher_clues',
      headers: { 'Content-Type' => 'application/json' },
      body:  request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end
end
