module ActiveRecordExtension

  extend ActiveSupport::Concern

  module ClassMethods
    def pluck_with_keys(*keys)
      self.pluck(*keys).map{ |plucked_values|
        Hash[keys.zip(plucked_values.kind_of?(Array)? plucked_values : [plucked_values])]
      }
    end
  end

end

# include the extension 
ActiveRecord::Base.send(:include, ActiveRecordExtension)