# frozen_string_literal: true

Rails.application.config.to_prepare do
  GraphQL::Execution::Interpreter::Runtime.class_eval do
    alias_method :continue_value_old, :continue_value
    # gql args: path, value, parent_type, field, is_non_null, ast_node
    def continue_value(*args)
      value = args[1]
      ast_node = args[5]
      field = args[3]
      type_klass = field.owner
      if !value.is_a?(ActiveRecord::Relation) || value.loaded? || !type_klass.respond_to?(:preloads)
        return continue_value_old(*args)
      end

      klass = GraphqlPreloadQueries::Extensions::Preload
      klass.preload_associations(value, ast_node, type_klass)
    end
  end
end
