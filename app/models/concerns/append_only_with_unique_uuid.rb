module AppendOnlyWithUniqueUuid
  extend ActiveSupport::Concern

  include HasUniqueUuid

  def readonly?
    !new_record?
  end

  class_methods do
    def append(attributes_array)
      records = [attributes_array].flatten.map { |attributes| new(attributes) }
      import_block = -> {
        # We use validate: false here because the controller schemas and the DB
        # already enforce the presence/uniqueness/data type validations
        # ON CONFLICT DO NOTHING is used so we ignore duplicate inserts
        # We ignore duplicate imports (same uuid)
        # but explode if other attributes collide while the uuid is different
        import records, validate: false, on_duplicate_key_ignore: { conflict_target: [:uuid] }
      }

      connection.transaction_open? ? import_block.call : transaction(&import_block)
    end
  end
end
