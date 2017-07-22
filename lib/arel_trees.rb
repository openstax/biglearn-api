# Makes trees of binary ARel nodes that are as shallow as possible
# to improve SQL generation speed and avoid stack overflow
# Returns nil if the given array is empty
module ArelTrees

  def self.or_tree(array_of_queries)
    node_tree Arel::Nodes::Or, array_of_queries
  end

  def self.union_all_tree(array_of_queries)
    node_tree Arel::Nodes::UnionAll, array_of_queries
  end

  protected

  def self.node_tree(node_class, array_of_queries)
    return array_of_queries.first if array_of_queries.size <= 1

    node_tree(
      node_class, array_of_queries.each_slice(2).map do |first_query, second_query|
        second_query.nil? ? first_query : node_class.new(first_query, second_query)
      end
    )
  end

end
