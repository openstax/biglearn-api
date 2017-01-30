require 'rails_helper'

RSpec.describe AppendOnly, type: :concern do
  let(:test_class)    do
    Class.new do
      attr_accessor :new_record

      def initialize
        self.new_record = true
      end

      def save
        self.new_record = false
      end

      def new_record?
        new_record
      end

      include AppendOnly
    end
  end

  let(:test_instance) { test_class.new }

  it 'makes instances of the including class append-only' do
    expect(test_instance.new_record?).to eq true
    expect(test_instance.readonly?).to eq false
    test_instance.save
    expect(test_instance.new_record?).to eq false
    expect(test_instance.readonly?).to eq true
  end
end
