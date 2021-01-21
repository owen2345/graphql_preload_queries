# frozen_string_literal: true

require 'rails_helper'
RSpec.describe GraphqlPreloadQueries::Extensions::Preload do
  describe 'when filtering preloads' do
    it 'applies exp. preloads if query includes exp. preloads' do
      node = query_node({ allUsers: %i[id name] })
      preload_config = { 'allUsers' => :users }
      res = filter_preloads(node, preload_config)
      expect(res).to eql({ users: {} })
    end

    it 'does not apply preload if query does not include exp. preload' do
      node = query_node({ allUsers: %i[id name] })
      preload_config = { 'users' => :users } # not preloading for "allUsers"
      res = filter_preloads(node, preload_config)
      expect(res).to eql({})
    end

    it 'uses query name as the preload association key if :preload not defined' do
      node = query_node({ users: %i[id name friends { id }] })
      preload_config = { users: { friends: :friends } } # does not include :preload
      res = filter_preloads(node, preload_config)
      expect(res).to eql({ users: { friends: {} } })
    end

    it 'supports for multiple query names: preload "users" when "users" or
        "allUsers" are present in the query' do
      node = query_node({ allUsers: %i[id name] })
      preload_config = { 'users|allUsers' => :users }
      res = filter_preloads(node, preload_config)
      expect(res).to eql({ users: {} })
    end

    it 'supports for deep preload keys: preload "assigned_friends.user" when
        "friends" is present inside "users" query' do
      node = query_node({ allUsers: { id: true, friends: %i[id name] } })
      preload_config = { allUsers: { preload: :users, friends: 'assigned_friends.user' } }
      res = filter_preloads(node, preload_config)
      expect(res).to eql({ users: { assigned_friends: { user: {} } } })
    end

    it 'applies exp. deep preloads if query includes exp. preloads' do
      node = query_node(
        {
          users: { id: true,
                   closeFriends: { id: true, name: true, allComments: %i[id msg] } }
        }
      )
      friends_preload = { closeFriends: { allComments: :comments } }
      preload_config = { users: friends_preload }
      res = filter_preloads(node, preload_config)
      expect(res).to eql({ users: { close_friends: { comments: {} } } })
    end
  end

  private

  def filter_preloads(node, preload_conf)
    described_class.send(:filter_preloads, node, preload_conf)
  end

  # @param data (Hash|Array)
  def query_node(data, key = 'root')
    items = [Hash, Array].include?(data.class) ? build_selections(data) : []
    OpenStruct.new(name: key, selections: items)
  end

  # @param data (Hash)
  def build_selections(data)
    data.map do |key, val|
      query_node(val, key)
    end
  end
end
