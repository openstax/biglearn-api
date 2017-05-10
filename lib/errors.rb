module Errors
  class AppError < StandardError;

    attr_reader :nested_exception
    attr_reader :local_errors
    attr_reader :location

    def initialize(*local_errors)
      @local_errors = Array(local_errors).flatten
      @nested_exception = $!
      @location = caller[1]
    end

    def errors
      nested_errors =
        if @nested_exception.nil?
          []
        elsif @nested_exception.respond_to? :errors
          @nested_exception.errors
        else
          Array(@nested_exception.message)
        end
      local_errors + nested_errors
    end

    def raw_message_lines
      nested_message_lines =
        if @nested_exception.nil?
          []
        elsif @nested_exception.respond_to? :raw_message_lines
          @nested_exception.raw_message_lines
        else
          "#{@nested_exception.class.name} [#{@nested_exception.backtrace.first}]: #{@nested_exception.message}"
        end
      ["#{self.class.name} [#{self.location}]: #{self.local_errors}"] + Array(nested_message_lines)
    end

    def inspect
      raw_message_lines.each_with_index.collect{ |line, idx|
        ' '*2*idx + line
      }
    end

    def backtrace
      if @nested_exception
        @nested_exception.backtrace
      else
        super
      end
    end

  end

  class AppRequestValidationError < AppError; end
  class AppRequestHeaderError < AppRequestValidationError; end
  class AppRequestSchemaError < AppRequestValidationError; end

  class AppResponseValidationError < AppError; end
  class AppResponseStatusError < AppResponseValidationError; end
  class AppResponseSchemaError < AppResponseValidationError; end

end
