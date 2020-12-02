# frozen_string_literal: true

# preload resolver for mutations
Rails.application.config.to_prepare do
  GraphQL::Schema::Mutation.class_eval do
    # TODO: auto recover type_klass using result key
    # Add corresponding preloads to mutation results
    # @param gql_result_key (String | Sym)
    # @param collection (ActiveCollection)
    # @param type_klass (GQL TypeClass)
    def include_gql_preloads(gql_result_key, collection, type_klass = nil)
      type_klass ||= preload_type_klass(gql_result_key.to_s)
      klass = GraphqlPreloadQueries::Extensions::Preload
      ast_node = preload_find_node(gql_result_key)
      klass.preload_associations(collection, ast_node, type_klass)
    end

    private

    def preload_find_node(key)
      main_node = context.query.document.definitions.first.selections.first
      main_node.selections.find { |node_i| node_i.name == key.to_s }
    end

    # @param result_key: String
    def preload_type_klass(result_key)
      res = self.class.fields[result_key].instance_variable_get(:@return_type_expr)
      res.is_a?(Array) ? res.first : res
    end
  end
end
