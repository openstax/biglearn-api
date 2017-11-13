module NotifyingAppendOnlyWithUniqueUuid
  extend ActiveSupport::Concern

  include AppendOnlyWithUniqueUuid

  included do
    class_attribute :notify_channel, :notify_payload_method
    self.notify_channel = table_name
    self.notify_payload_method = :uuid
  end

  class_methods do
    def append(attributes_array)
      notify_block = ->(records) {
        payload = sanitize records.map { |record| record.send notify_payload_method }.uniq.join(',')

        connection.execute "NOTIFY #{notify_channel}, #{payload}"
      }

      super(attributes_array).tap do |records|
        connection.transaction_open? ? notify_block.call(records) :
                                       transaction { notify_block.call(records) }
      end
    end
  end
end
