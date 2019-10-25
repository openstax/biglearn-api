require 'rails_helper'

RSpec.describe ExercisesController, type: :request do
  let(:given_algorithm_name)          { 'biglearn_sparfa' }

  let(:given_request_uuid_1)          { SecureRandom.uuid }
  let(:given_request_uuid_2)          { SecureRandom.uuid }
  let(:given_calculation_uuid_1)      { SecureRandom.uuid }
  let(:given_calculation_uuid_2)      { SecureRandom.uuid }
  let(:given_ecosystem_matrix_uuid_1) { SecureRandom.uuid }
  let(:given_ecosystem_matrix_uuid_2) { SecureRandom.uuid }

  context '#fetch_assignment_pes' do
    let(:given_assignment_uuid_1)   { SecureRandom.uuid }
    let(:given_max_num_exercises_1) { rand(10) }
    let(:given_spy_info_1)          { { test: true } }
    let(:given_assignment_uuid_2)   { SecureRandom.uuid }
    let(:given_max_num_exercises_2) { rand(10) }
    let(:given_spy_info_2)          { {} }

    let(:given_pe_requests)         do
      [
        {
          request_uuid: given_request_uuid_1,
          assignment_uuid: given_assignment_uuid_1,
          algorithm_name: given_algorithm_name,
          max_num_exercises: given_max_num_exercises_1
        },
        {
          request_uuid: given_request_uuid_2,
          assignment_uuid: given_assignment_uuid_2,
          algorithm_name: given_algorithm_name,
          max_num_exercises: given_max_num_exercises_2
        }
      ]
    end

    let(:target_pe_responses)       do
      [
        {
          request_uuid: given_request_uuid_1,
          assignment_uuid: given_assignment_uuid_1,
          calculation_uuid: given_calculation_uuid_1,
          ecosystem_matrix_uuid: given_ecosystem_matrix_uuid_1,
          exercise_uuids: given_max_num_exercises_1.times.map{ SecureRandom.uuid },
          assignment_status: 'assignment_ready',
          spy_info: given_spy_info_1
        },
        {
          request_uuid: given_request_uuid_2,
          assignment_uuid: given_assignment_uuid_2,
          calculation_uuid: given_calculation_uuid_2,
          ecosystem_matrix_uuid: given_ecosystem_matrix_uuid_2,
          exercise_uuids: [],
          assignment_status: 'assignment_unready',
          spy_info: given_spy_info_2
        }
      ]
    end

    let(:request_payload) { { pe_requests: given_pe_requests } }

    let(:target_result)   { { pe_responses: target_pe_responses } }
    let(:target_response) { target_result }

    let(:service_double)  do
      object_double(Services::FetchAssignmentPes::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
      end
    end

    before(:each)         do
      allow(Services::FetchAssignmentPes::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = fetch_assignment_pes(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = fetch_assignment_pes(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the FetchAssignmentPes service is called with the correct course data" do
        response_status, response_body = fetch_assignment_pes(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_response" do
        response_status, response_body = fetch_assignment_pes(request_payload: request_payload)
        expect(response_body.deep_symbolize_keys).to eq(target_response)
      end
    end
  end

  context '#fetch_assignment_spes' do
    let(:given_assignment_uuid_1)   { SecureRandom.uuid }
    let(:given_max_num_exercises_1) { rand(10) }
    let(:given_spy_info_1)          { { test: true } }
    let(:given_assignment_uuid_2)   { SecureRandom.uuid }
    let(:given_max_num_exercises_2) { rand(10) }
    let(:given_spy_info_2)          { {} }

    let(:given_spe_requests)        do
      [
        {
          request_uuid: given_request_uuid_1,
          assignment_uuid: given_assignment_uuid_1,
          algorithm_name: given_algorithm_name,
          max_num_exercises: given_max_num_exercises_1
        },
        {
          request_uuid: given_request_uuid_2,
          assignment_uuid: given_assignment_uuid_2,
          algorithm_name: given_algorithm_name,
          max_num_exercises: given_max_num_exercises_2
        }
      ]
    end

    let(:target_spe_responses)      do
      [
        {
          request_uuid: given_request_uuid_1,
          assignment_uuid: given_assignment_uuid_1,
          calculation_uuid: given_calculation_uuid_1,
          ecosystem_matrix_uuid: given_ecosystem_matrix_uuid_1,
          exercise_uuids: given_max_num_exercises_1.times.map{ SecureRandom.uuid },
          assignment_status: 'assignment_ready',
          spy_info: given_spy_info_1
        },
        {
          request_uuid: given_request_uuid_2,
          assignment_uuid: given_assignment_uuid_2,
          calculation_uuid: given_calculation_uuid_2,
          ecosystem_matrix_uuid: given_ecosystem_matrix_uuid_2,
          exercise_uuids: [],
          assignment_status: 'assignment_unready',
          spy_info: given_spy_info_2
        }
      ]
    end

    let(:request_payload) { { spe_requests: given_spe_requests } }

    let(:target_result)   { { spe_responses: target_spe_responses } }
    let(:target_response) { target_result }

    let(:service_double)  do
      object_double(Services::FetchAssignmentSpes::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
      end
    end

    before(:each)                   do
      allow(Services::FetchAssignmentSpes::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = fetch_assignment_spes(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = fetch_assignment_spes(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the FetchAssignmentSpes service is called with the correct course data" do
        response_status, response_body = fetch_assignment_spes(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_response" do
        response_status, response_body = fetch_assignment_spes(request_payload: request_payload)
        expect(response_body.deep_symbolize_keys).to eq(target_response)
      end
    end
  end

  context '#fetch_practice_worst_areas' do
    let(:given_student_uuid_1)         { SecureRandom.uuid }
    let(:given_max_num_exercises_1)    { rand(10) }
    let(:given_spy_info_1)             { { test: true } }
    let(:given_student_uuid_2)         { SecureRandom.uuid }
    let(:given_max_num_exercises_2)    { rand(10) }
    let(:given_spy_info_2)             { {} }

    let(:given_worst_areas_requests)   do
      [
        {
          request_uuid: given_request_uuid_1,
          student_uuid: given_student_uuid_1,
          algorithm_name: given_algorithm_name,
          max_num_exercises: given_max_num_exercises_1
        },
        {
          request_uuid: given_request_uuid_2,
          student_uuid: given_student_uuid_2,
          algorithm_name: given_algorithm_name,
          max_num_exercises: given_max_num_exercises_2
        }
      ]
    end

    let(:target_worst_areas_responses) do
      [
        {
          request_uuid: given_request_uuid_1,
          student_uuid: given_student_uuid_1,
          calculation_uuid: given_calculation_uuid_1,
          ecosystem_matrix_uuid: given_ecosystem_matrix_uuid_1,
          exercise_uuids: given_max_num_exercises_1.times.map{ SecureRandom.uuid },
          student_status: 'student_ready',
          spy_info: given_spy_info_1
        },
        {
          request_uuid: given_request_uuid_2,
          student_uuid: given_student_uuid_2,
          calculation_uuid: given_calculation_uuid_2,
          ecosystem_matrix_uuid: given_ecosystem_matrix_uuid_2,
          exercise_uuids: [],
          student_status: 'student_unready',
          spy_info: given_spy_info_2
        }
      ]
    end

    let(:request_payload) do
      { worst_areas_requests: given_worst_areas_requests }
    end

    let(:target_result)   do
      { worst_areas_responses: target_worst_areas_responses }
    end
    let(:target_response) { target_result }

    let(:service_double)  do
      object_double(Services::FetchPracticeWorstAreasExercises::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
      end
    end

    before(:each)         do
      allow(Services::FetchPracticeWorstAreasExercises::Service).to(
        receive(:new).and_return(service_double)
      )
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = fetch_practice_worst_areas(
          request_payload: request_payload
        )
      end

      it "the response has status 200 (success)" do
        response_status, response_body = fetch_practice_worst_areas(
          request_payload: request_payload
        )
        expect(response_status).to eq(200)
      end

      it "the FetchAssignmentPes service is called with the correct course data" do
        response_status, response_body = fetch_practice_worst_areas(
          request_payload: request_payload
        )
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_response" do
        response_status, response_body = fetch_practice_worst_areas(
          request_payload: request_payload
        )
        expect(response_body.deep_symbolize_keys).to eq(target_response)
      end
    end
  end

  context '#update_assignment_pes' do
    let(:given_assignment_uuid_1)     { SecureRandom.uuid }
    let(:given_exercise_uuid_count_1) { rand(10) }
    let(:given_spy_info_1)            { { test: true } }
    let(:given_assignment_uuid_2)     { SecureRandom.uuid }
    let(:given_exercise_uuid_count_2) { rand(10) }
    let(:given_spy_info_2)            { {} }

    let(:given_pe_update_requests)    do
      [
        {
          request_uuid: given_request_uuid_1,
          calculation_uuid: given_calculation_uuid_1,
          ecosystem_matrix_uuid: given_ecosystem_matrix_uuid_1,
          assignment_uuid: given_assignment_uuid_1,
          algorithm_name: given_algorithm_name,
          exercise_uuids: given_exercise_uuid_count_1.times.map{ SecureRandom.uuid },
          spy_info: given_spy_info_1
        },
        {
          request_uuid: given_request_uuid_2,
          calculation_uuid: given_calculation_uuid_2,
          ecosystem_matrix_uuid: given_ecosystem_matrix_uuid_2,
          assignment_uuid: given_assignment_uuid_2,
          algorithm_name: given_algorithm_name,
          exercise_uuids: given_exercise_uuid_count_2.times.map{ SecureRandom.uuid },
          spy_info: given_spy_info_2
        }
      ]
    end

    let(:target_pe_update_responses)  do
      [
        {
          request_uuid: given_request_uuid_1,
          update_status: 'accepted'
        },
        {
          request_uuid: given_request_uuid_2,
          update_status: 'accepted'
        }
      ]
    end

    let(:request_payload) { { pe_updates: given_pe_update_requests } }

    let(:target_result)   { { pe_update_responses: target_pe_update_responses } }
    let(:target_response) { target_result }

    let(:service_double)  do
      object_double(Services::UpdateAssignmentPes::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
      end
    end

    before(:each)         do
      allow(Services::UpdateAssignmentPes::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = update_assignment_pes(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = update_assignment_pes(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the UpdateAssignmentPes service is called with the correct course data" do
        response_status, response_body = update_assignment_pes(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_response" do
        response_status, response_body = update_assignment_pes(request_payload: request_payload)
        expect(response_body.deep_symbolize_keys).to eq(target_response)
      end
    end
  end

  context '#update_assignment_spes' do
    let(:given_assignment_uuid_1)     { SecureRandom.uuid }
    let(:given_exercise_uuid_count_1) { rand(10) }
    let(:given_spy_info_1)            { { test: true } }
    let(:given_assignment_uuid_2)     { SecureRandom.uuid }
    let(:given_exercise_uuid_count_2) { rand(10) }
    let(:given_spy_info_2)            { {} }

    let(:given_spe_update_requests)   do
      [
        {
          request_uuid: given_request_uuid_1,
          calculation_uuid: given_calculation_uuid_1,
          ecosystem_matrix_uuid: given_ecosystem_matrix_uuid_1,
          assignment_uuid: given_assignment_uuid_1,
          algorithm_name: given_algorithm_name,
          exercise_uuids: given_exercise_uuid_count_1.times.map{ SecureRandom.uuid },
          spy_info: given_spy_info_1
        },
        {
          request_uuid: given_request_uuid_2,
          calculation_uuid: given_calculation_uuid_2,
          ecosystem_matrix_uuid: given_ecosystem_matrix_uuid_2,
          assignment_uuid: given_assignment_uuid_2,
          algorithm_name: given_algorithm_name,
          exercise_uuids: given_exercise_uuid_count_2.times.map{ SecureRandom.uuid },
          spy_info: given_spy_info_2
        }
      ]
    end

    let(:target_spe_update_responses) do
      [
        {
          request_uuid: given_request_uuid_1,
          update_status: 'accepted'
        },
        {
          request_uuid: given_request_uuid_2,
          update_status: 'accepted'
        }
      ]
    end

    let(:request_payload) { { spe_updates: given_spe_update_requests } }

    let(:target_result)   { { spe_update_responses: target_spe_update_responses } }
    let(:target_response) { target_result }

    let(:service_double)  do
      object_double(Services::UpdateAssignmentSpes::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
      end
    end

    before(:each)                   do
      allow(Services::UpdateAssignmentSpes::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = update_assignment_spes(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = update_assignment_spes(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the UpdateAssignmentSpes service is called with the correct course data" do
        response_status, response_body = update_assignment_spes(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_response" do
        response_status, response_body = update_assignment_spes(request_payload: request_payload)
        expect(response_body.deep_symbolize_keys).to eq(target_response)
      end
    end
  end

  context '#update_practice_worst_areas' do
    let(:given_student_uuid_1)        { SecureRandom.uuid }
    let(:given_exercise_uuid_count_1) { rand(10) }
    let(:given_spy_info_1)            { { test: true } }
    let(:given_student_uuid_2)        { SecureRandom.uuid }
    let(:given_exercise_uuid_count_2) { rand(10) }
    let(:given_spy_info_2)            { {} }

    let(:given_worst_areas_update_requests)   do
      [
        {
          request_uuid: given_request_uuid_1,
          calculation_uuid: given_calculation_uuid_1,
          ecosystem_matrix_uuid: given_ecosystem_matrix_uuid_1,
          student_uuid: given_student_uuid_1,
          algorithm_name: given_algorithm_name,
          exercise_uuids: given_exercise_uuid_count_1.times.map{ SecureRandom.uuid },
          spy_info: given_spy_info_1
        },
        {
          request_uuid: given_request_uuid_2,
          calculation_uuid: given_calculation_uuid_2,
          ecosystem_matrix_uuid: given_ecosystem_matrix_uuid_2,
          student_uuid: given_student_uuid_2,
          algorithm_name: given_algorithm_name,
          exercise_uuids: given_exercise_uuid_count_2.times.map{ SecureRandom.uuid },
          spy_info: given_spy_info_2
        }
      ]
    end

    let(:target_worst_areas_update_responses) do
      [
        {
          request_uuid: given_request_uuid_1,
          update_status: 'accepted'
        },
        {
          request_uuid: given_request_uuid_2,
          update_status: 'accepted'
        }
      ]
    end

    let(:request_payload) { { practice_worst_areas_updates: given_worst_areas_update_requests } }

    let(:target_result)   { { practice_worst_areas_update_responses: target_worst_areas_update_responses } }
    let(:target_response) { target_result }

    let(:service_double)  do
      object_double(Services::UpdatePracticeWorstAreasExercises::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
      end
    end

    before(:each)                   do
      allow(Services::UpdatePracticeWorstAreasExercises::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = update_practice_worst_areas(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = update_practice_worst_areas(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the UpdatePracticeWorstAreasExercises service is called with the correct course data" do
        response_status, response_body = update_practice_worst_areas(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_response" do
        response_status, response_body = update_practice_worst_areas(request_payload: request_payload)
        expect(response_body.deep_symbolize_keys).to eq(target_response)
      end
    end
  end

  protected

  def fetch_assignment_pes(request_payload:)
    make_post_request(
      route: '/fetch_assignment_pes',
      headers: { 'Content-Type' => 'application/json' },
      body:  request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end

  def fetch_assignment_spes(request_payload:)
    make_post_request(
      route: '/fetch_assignment_spes',
      headers: { 'Content-Type' => 'application/json' },
      body:  request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end

  def fetch_practice_worst_areas(request_payload:)
    make_post_request(
      route: '/fetch_practice_worst_areas_exercises',
      headers: { 'Content-Type' => 'application/json' },
      body:  request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end

  def update_assignment_pes(request_payload:)
    make_post_request(
      route: '/update_assignment_pes',
      headers: { 'Content-Type' => 'application/json' },
      body:  request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end

  def update_assignment_spes(request_payload:)
    make_post_request(
      route: '/update_assignment_spes',
      headers: { 'Content-Type' => 'application/json' },
      body:  request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end

  def update_practice_worst_areas(request_payload:)
    make_post_request(
      route: '/update_practice_worst_areas_exercises',
      headers: { 'Content-Type' => 'application/json' },
      body:  request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end
end
