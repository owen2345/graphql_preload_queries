# frozen_string_literal: true

require 'graphql_preload_queries/extensions/preload'

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

      # Fix: omit non expected "extras" param auto provided by graphql
      define_method(key) { |_omit_non_used_args| object.send(key) } unless method_defined? key
    end
  end
end
