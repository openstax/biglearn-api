require 'rails_helper'
require_relative 'shared_examples_for_append_only_with_unique_uuid'

RSpec.describe AppendOnlyWithUniqueUuid, type: :concern do
  include_examples 'append_only_with_unique_uuid'
end
