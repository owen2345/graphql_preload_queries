# frozen_string_literal: true

require 'graphql/execution/interpreter/runtime'
module GraphqlPreloadQueries::PatchContinueValue # rubocop:disable Style/ClassAndModuleChildren:
  # gql args: path, value, parent_type, field, is_non_null, ast_node
  def continue_value(*args)
    value = args[1]
    ast_node = args[5]
    field = args[3]
    type_klass = field.owner
    is_active_record = value.is_a?(ActiveRecord::Relation)
    return super if !is_active_record || value.loaded? || !type_klass.respond_to?(:preloads)

    klass = GraphqlPreloadQueries::Extensions::Preload
    klass.preload_associations(value, ast_node, type_klass)
  end
end
GraphQL::Execution::Interpreter::Runtime.prepend GraphqlPreloadQueries::PatchContinueValue
