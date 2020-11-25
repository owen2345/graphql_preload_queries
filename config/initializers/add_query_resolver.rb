# preload resolver for queries
Rails.application.config.to_prepare do
  Types::QueryType.class_eval do
    # Add corresponding preloads to query results
    #   Note: key is automatically calculated based on method name
    # @param data (ActiveCollection)
    # @param preload_config (Same as Field: field[:preload])
    def resolve_preloads(data, preload_config)
      key = caller[0][/`.*'/][1..-2]
      klass = GraphqlPreloadQueries::Extensions::Preload
      node = context.query.document.definitions.first.selections.find { |node_i| node_i.name == key.to_s }
      return data unless node

      # relay support (TODO: add support to skip when not using relay)
      if ['nodes', 'edges'].include?(node.selections.first.name)
        node = node.selections.first
      end
      klass.resolve_preloads(data, node, preload_config)
    end
  end
end
