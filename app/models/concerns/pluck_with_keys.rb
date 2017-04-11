module PluckWithKeys

  extend ActiveSupport::Concern

  module ClassMethods
    def pluck_with_keys(first_key, *other_keys)
      if first_key.class == Hash
        select_keys = first_key.keys
        named_keys = first_key.values
      else
        select_keys = [first_key].concat(other_keys)
        named_keys = select_keys
      end

      pluck(*select_keys).map do |plucked_values|
        Hash[ *named_keys.zip([plucked_values].flatten(1)).flatten(1) ]
      end
    end
  end

end
