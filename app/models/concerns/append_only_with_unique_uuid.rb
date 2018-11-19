module AppendOnlyWithUniqueUuid
  extend ActiveSupport::Concern

  include UniqueUuid

  def readonly?
    !new_record?
  end

  included do
    class_attribute :sequence_number_association_class,
                    :sequence_number_association_primary_key,
                    :sequence_number_association_foreign_key
  end

  class_methods do
    def sequence_number_association(association)
      reflection = reflect_on_association association
      self.sequence_number_association_class = reflection.klass
      self.sequence_number_association_primary_key = reflection.association_primary_key
      self.sequence_number_association_foreign_key = reflection.foreign_key
    end

    def append(attributes_array)
      attributes_array = [attributes_array].flatten.map(&:deep_symbolize_keys)

      unless sequence_number_association_class.nil?
        attributes_by_key = attributes_array.group_by do |attributes|
          attributes[sequence_number_association_foreign_key]
        end
        mapped_attributes_by_key = {}
        columns = Set[ :sequence_number ]
        attributes_by_key.each do |key, attributes|
          last_attributes = attributes.max_by { |attrs| attrs[:sequence_number] }
          extra_attributes = last_attributes[:sequence_number_association_extra_attributes] || {}
          mapped_attributes_by_key[key] = {
            sequence_number: last_attributes[:sequence_number] + 1
          }.merge extra_attributes
          columns += extra_attributes.keys
        end
        sequence_number_association_records = sequence_number_association_class.where(
          sequence_number_association_primary_key => mapped_attributes_by_key.keys
        ).order(sequence_number_association_primary_key).lock('FOR NO KEY UPDATE').to_a
        sequence_number_association_records_to_import = []
        sequence_number_association_records.each do |record|
          key = record.send sequence_number_association_primary_key
          attributes = mapped_attributes_by_key[key]
          next if attributes[:sequence_number] <= record.sequence_number

          attributes.each { |key, value| record.send "#{key}=", value }
          sequence_number_association_records_to_import << record
        end
        sequence_number_association_class.import sequence_number_association_records_to_import,
                                                 validate: false, on_duplicate_key_update: {
          conflict_target: [ sequence_number_association_primary_key ], columns: columns.to_a
        }
      end

      records = attributes_array.map do |attributes|
        new(attributes.except(:sequence_number_association_extra_attributes))
      end
      import_block = -> do
        # We use validate: false here because the controller schemas and the DB
        # already enforce the presence/uniqueness/data type validations
        # ON CONFLICT DO NOTHING is used so we ignore duplicate inserts
        # We ignore duplicate imports (same uuid)
        # but explode if other attributes collide while the uuid is different
        import records, validate: false, on_duplicate_key_ignore: { conflict_target: [:uuid] }
      end

      connection.transaction_open? ? import_block.call : transaction(&import_block)
    end
  end
end
