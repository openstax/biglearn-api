require 'rails_helper'

RSpec.describe UniqueUuid, type: :concern do
  let(:test_class) do
    Class.new do
      def self.validates(*args)
      end
    end
  end

  it 'sets up validations for the uuid field' do
    expect(test_class).to receive(:validates).with(:uuid, presence: true, uniqueness: true)
    test_class.class_exec { include UniqueUuid }
  end
end
