require "graphql_preload_queries/extensions/preload"

Rails.application.config.to_prepare do
  # Custom preload field for Object types
  Types::BaseObject.class_eval do
    # @param key field[:key]
    # @param type field[:type]
    # @param settings field[:settings] ++ { preload: {} }
    #   preload: (Hash) { allPosts: [:posts, { author: :author }] }
    #   ==> <cat1>.preload(posts: :author) // if author and posts are in query
    #   ==> <cat1>.preload(:posts) // if only author is in the query
    #   ==> <cat1>.preload() // if both of them are not in the query
    # TODO: ability to merge extensions + extras
    def self.preload_field(key, type, settings = {})
      klass = GraphqlPreloadQueries::Extensions::Preload
      custom_attrs = {
        extras: [:ast_node],
        extensions: [klass => settings.delete(:preload)]
      }
      field key, type, settings.merge(custom_attrs)
    end
  end

  # preload resolver for queries
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

  # preload resolver for mutations
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
