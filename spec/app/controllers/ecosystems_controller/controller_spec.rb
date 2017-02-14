require 'rails_helper'

RSpec.describe EcosystemsController, type: :request do
  context '#create_ecosystem' do
    let(:given_ecosystem_uuid) { SecureRandom.uuid }
    let(:given_book)           { {} }
    let(:given_exercises)      { [] }

    let(:request_payload)      do
      {
        ecosystem_uuid: given_ecosystem_uuid,
        book: given_book,
        exercises: given_exercises
      }
    end

    let(:target_result)        { { created_ecosystem_uuid: given_ecosystem_uuid } }
    let(:target_response)      { target_result }

    let(:service_double)       do
      object_double(Services::CreateEcosystem::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(request_payload).and_return(target_result)
      end
    end

    before(:each) do
      allow(Services::CreateEcosystem::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = create_ecosystem(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = create_ecosystem(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the CreateEcosystem service is called with the correct course data" do
        response_status, response_body = create_ecosystem(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_response" do
        response_status, response_body = create_ecosystem(request_payload: request_payload)
        expect(response_body).to eq(target_response.deep_stringify_keys)
      end
    end
  end

  context '#fetch_ecosystem_metadatas' do
    let(:ecosystems_count)        { rand(10) + 1 }

    let(:target_result)           do
      {
        ecosystem_responses: ecosystems_count.times.map{
          {
            uuid: SecureRandom.uuid,
            book_uuid: SecureRandom.uuid
          }
        }
      }
    end

    let(:service_double)          do
      object_double(Services::FetchEcosystemMetadatas::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).and_return(target_result)
      end
    end

    before(:each) do
      allow(Services::FetchEcosystemMetadatas::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = fetch_ecosystem_metadatas()
      end

      it "the response has status 200 (success)" do
        response_status, response_body = fetch_ecosystem_metadatas()
        expect(response_status).to eq(200)
      end

      it "the FetchEcosystemMetadatas service is called with the correct course data" do
        response_status, response_body = fetch_ecosystem_metadatas()
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_result" do
        response_status, response_body = fetch_ecosystem_metadatas()
        expect(response_body).to eq(target_result.deep_stringify_keys)
      end
    end
  end

  protected

  def create_ecosystem(request_payload:)
    make_post_request(
      route: '/create_ecosystem',
      headers: { 'Content-Type' => 'application/json' },
      body:  request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end

  def fetch_ecosystem_metadatas()
    make_post_request(
      route: '/fetch_ecosystem_metadatas'
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end
end
