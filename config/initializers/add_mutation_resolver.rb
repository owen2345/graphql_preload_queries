# frozen_string_literal: true

# preload resolver for mutations
Rails.application.config.to_prepare do
  GraphQL::Schema::Mutation.class_eval do
    # Add corresponding preloads to mutation results
    # @param key (sym) key of the query
    # @param data (ActiveCollection)
    # @param preload_config (Same as Field: field[:preload])
    def resolve_preloads(key, data, preload_config)
      node = find_node(key)
      return data unless node

      # relay support (TODO: add support to skip when not using relay)
      node = node.selections.first if %w[nodes edges].include?(node.selections.first.name)
      GraphqlPreloadQueries::Extensions::Preload.resolve_preloads(data, node, preload_config)
    end

    private

    def find_node(key)
      main_node = context.query.document.definitions.first.selections.first
      main_node.selections.find { |node_i| node_i.name == key.to_s }
    end
  end
end
