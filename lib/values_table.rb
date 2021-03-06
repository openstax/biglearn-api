class ValuesTable
  attr_reader :values_array

  # values_array is an array of arrays
  # Each array entry becomes a row in the values table
  def initialize(values_array)
    @values_array = values_array
  end

  def to_sql
    raise 'ValuesTable cannot be given an empty array' if values_array.empty?

    "VALUES #{values_array.map do |values|
      raise 'ValuesTable cannot be given an array containing empty arrays' if values.empty?
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

    ActiveRecord::Base.connection.quote value
  end
end
