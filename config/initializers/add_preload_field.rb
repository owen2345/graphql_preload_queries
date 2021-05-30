# frozen_string_literal: true

require 'graphql_preload_queries/extensions/preload'

Rails.application.config.to_prepare do
  Types::BaseObject.class_eval do
    class << self
      def preloads
        @preloads ||= {}
      end

      # @param key (Symbol|String)
      # @param preload (Symbol|String or Symbol|String|Hash)
      # @Sample:
      ## key argument supports for multiple query names
      #    add_preload('users|allUsers', :users)
      ## preload argument indicates the association name to be preloaded
      #    add_preload(:allUsers, :users)
      ## preload argument supports for nested associations
      #    add_preload(:inactiveUsers, 'inactivated_users.user')
      ## "preload" key should be specified to indicate the association name
      #    add_preload(:allUsers, { preload: :users, 'allComments|comments' => :comments } })
      ## preload key can be omitted to use the same name as the key
      #    add_preload(:users, { 'allComments|comments' => :comments } })
      def add_preload(key, preload = key)
        preload ||= key
        raise('Invalid preload query key') if [String, Symbol].exclude?(key.class)
        raise('Invalid preload preload key') if [String, Symbol, Hash].exclude?(preload.class)

        preload[:preload] ||= key if preload.is_a?(Hash)
        key = GraphQL::Schema::Member::BuildType.camelize(key.to_s)
        preloads[key] = preload
      end

      alias_method :field_old, :field
      def field(*args, **kwargs, &block)
        preload = kwargs.delete(:preload)
        key = args[0]
        add_preload(key, preload == true ? key : preload) if preload
        field_old(*args, **kwargs, &block)
      end
    end
  end
end
