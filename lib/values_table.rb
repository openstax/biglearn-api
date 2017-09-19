class ValuesTable
  UUID_REGEX = /\A[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\z/i

  attr_reader :values_array

  # values_array is an array of arrays
  # Each array entry becomes a row in the values table
  def initialize(values_array)
    @values_array = values_array
  end

  def to_sql
    "VALUES #{values_array.map do |values|
      next if values.any? { |value| value.is_a?(Array) && value.empty? }

      "(#{values.map { |value| sanitize value }.join(', ')})"
    end.compact.join(', ')}"
  end

  def to_s
    to_sql
  end

  protected

  def sanitize(value)
    return "ARRAY[#{value.map { |val| sanitize val }.join(', ')}]" if value.is_a?(Array)

    sanitized_value = ActiveRecord::Base.sanitize value

    UUID_REGEX === value ? "#{sanitized_value}::uuid" : sanitized_value
  end
end
