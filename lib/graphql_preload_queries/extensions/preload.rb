# frozen_string_literal: true

# TODO: add generic resolver

module GraphqlPreloadQueries
  module Extensions
    class Preload < GraphQL::Schema::FieldExtension
      class << self
        # Add all the corresponding preloads to the collection
        # @param value (ActiveCollection)
        # @param @node (GqlNode)
        # @param @type_klass (GqlTypeKlass)
        # @return @data with necessary preloads
        def preload_associations(value, node, type_klass)
          apply_preloads(value, filter_preloads(node, type_klass.preloads || {}))
        end

        private

        def apply_preloads(collection, preloads)
          collection.eager_load(preloads)
        end

        # find all configured preloads inside a node
        def filter_preloads(node, preload_conf, root = nested_hash)
          return root unless node

          preload_conf.map do |key, sub_preload_conf|
            filter_preload(node, key, sub_preload_conf, root)
          end
          root
        end

        # find preloads under a specific key
        def filter_preload(node, key, preload_conf, root)
          sub_node = sub_node(node, key)
          multiple_preload = preload_conf.is_a?(Hash)
          return unless sub_node
          return add_preload_key(root, preload_conf, {}) unless multiple_preload

          child_root = nested_hash
          association_name = preload_conf[:preload] || key.to_s.underscore
          filter_preloads(sub_node, preload_conf, child_root)
          add_preload_key(root, association_name, child_root.presence || {})
        end

        def sub_node(node, key)
          is_relay_node = %w[nodes edges].include?(node.selections.first.name)
          node = node.selections.first if is_relay_node
          node.selections.find do |node_i|
            key.to_s.split('|').include?(node_i.name.to_s)
          end
        end

        # parse nested preload key and add it to the tree
        # Sample: parent_preload: "categories.users"
        #         ==> { categories: { users: [res here] } }
        def add_preload_key(root, key, value)
          key_path = key.to_s.split('.').map(&:to_sym)
          root.dig(*key_path)
          *path, last = key_path
          path.inject(root, :fetch)[last] = value
        end

        def nested_hash
          Hash.new { |h, k| h[k] = {} }
        end
      end
    end
  end
end
