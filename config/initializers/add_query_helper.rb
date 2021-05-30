# frozen_string_literal: true

# preload resolver for queries
Rails.application.config.to_prepare do
  Types::QueryType.class_eval do
    # Add corresponding preloads to query results
    #   Note: key is automatically calculated based on method name
    # @param collection (ActiveCollection)
    # @param type_klass (GQL TypeClass, default: calculates using return type)
    # @param query_key (String | Sym) Default method name
    def include_gql_preloads(collection, query_key: nil, type_klass: nil)
      query_key ||= caller_locations(1, 1)[0].label
      gql_result_key = GraphQL::Schema::Member::BuildType.camelize(query_key.to_s)
      type_klass ||= preload_type_klass(gql_result_key.to_s)
      klass = GraphqlPreloadQueries::Extensions::Preload
      ast_node = preload_find_node(gql_result_key)
      klass.preload_associations(collection, ast_node, type_klass)
    end

    private

    # @param key: Symbol
    def preload_find_node(key)
      main_node = context.query.document.definitions.first
      main_node.selections.find { |node_i| node_i.name == key.to_s }
    end

    # @param result_key: String
    def preload_type_klass(result_key)
      res = self.class.fields[result_key].instance_variable_get(:@return_type_expr)
      res.is_a?(Array) ? res.first : res
    end
  end
end
