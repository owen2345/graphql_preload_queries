# TODO: add generic resolver

module GraphqlPreloadQueries
  module Extensions
    class Preload < GraphQL::Schema::FieldExtension
      # extension to add eager loading when a field was already processed
      def resolve(object:, arguments:, **rest)
        klass = GraphqlPreloadQueries::Extensions::Preload
        res = yield(object, arguments)
        return res unless res

        klass.resolve_preloads(res, arguments[:ast_node], (options || {}))
      end

      class << self
        # Add all the corresponding preloads to the collection
        # @param data (ActiveCollection)
        # @return @data with preloads configured
        # Sample: resolve_preloads(Category.all, { allPosts: :posts })
        def resolve_preloads(data, query_node, preload_config)
          apply_preloads(data, filter_preloads(query_node, preload_config))
        end

        def apply_preloads(collection, preloads)
          collection.eager_load(preloads)
        end

        # find all configured preloads inside a node
        def filter_preloads(node, preload_conf, root = nested_hash)
          preload_conf.map do |key, sub_preload_conf|
            filter_preload(node, key, sub_preload_conf, root)
          end
          root
        end

        private

        # find preloads under a specific key
        def filter_preload(node, key, preload_conf, root)
          sub_node = node.selections.find do |node_i|
            key.to_s.split("|").include?(node_i.name.to_s)
          end

          multiple_preload = preload_conf.is_a?(Array)
          return unless sub_node
          return add_preload_key(root, preload_conf, []) unless multiple_preload

          child_root = nested_hash
          filter_preloads(sub_node, preload_conf[1], child_root)
          add_preload_key(root, preload_conf[0], child_root.presence || [])
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
