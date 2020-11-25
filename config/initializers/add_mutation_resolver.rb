# preload resolver for mutations
Rails.application.config.to_prepare do
  GraphQL::Schema::Mutation.class_eval do
    # Add corresponding preloads to mutation results
    # @param key (sym) key of the query
    # @param data (ActiveCollection)
    # @param preload_config (Same as Field: field[:preload])
    def resolve_preloads(key, data, preload_config)
      klass = GraphqlPreloadQueries::Extensions::Preload
      node = context.query.document.definitions.first.selections.first.selections.find { |node_i| node_i.name == key.to_s }
      return data unless node

      # relay support (TODO: add support to skip when not using relay)
      if ['nodes', 'edges'].include?(node.selections.first.name)
        node = node.selections.first
      end
      klass.resolve_preloads(data, node, preload_config)
    end
  end
end
