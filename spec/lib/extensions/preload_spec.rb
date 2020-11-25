
require 'rails_helper'
RSpec.describe GraphqlPreloadQueries::Extensions::Preload do
  describe 'when filtering preloads' do
    it 'applies exp. preloads if query includes exp. preloads' do
      node = query_node({ allUsers: [:id, :name] })
      preload_config = { 'allUsers' => :users }
      res = filter_preloads(node, preload_config)
      expect(res).to eql({ users: [] })
    end

    it 'does not apply preload if query does not include exp. preload' do
      node = query_node({ allUsers: [:id, :name] })
      preload_config = { 'users' => :users } # not preloading for "allUsers"
      res = filter_preloads(node, preload_config)
      expect(res).to eql({})
    end

    it 'supports for multiple query names: preload "users" when "users" or
        "allUsers" are present in the query' do
      node = query_node({ allUsers: [:id, :name] })
      preload_config = { 'users|allUsers' => :users }
      res = filter_preloads(node, preload_config)
      expect(res).to eql({ users: [] })
    end

    it 'supports for deep preload keys: preload "assigned_friends.user" when
        "friends" is present inside "users" query' do
      node = query_node({ users: { id: true, friends: [:id, :name] } })
      preload_config = { users: [:users, { friends: 'assigned_friends.user' }] }
      res = filter_preloads(node, preload_config)
      expect(res).to eql({ users: { assigned_friends: { user: [] } } })
    end

    it 'applies exp. deep preloads if query includes exp. preloads' do
      node = query_node(
        {
          users: { id: true,
                   closeFriends: { id: true, name: true,
                                   allComments: [:id, :msg] } } })
      friends_preload = { closeFriends: [:close_friends, { allComments: :comments }] }
      preload_config = { 'users' => [:users, friends_preload] }
      res = filter_preloads(node, preload_config)
      expect(res).to eql({ users: { close_friends: { comments: [] } } })
    end
  end

  private

  def filter_preloads(node, preload_conf)
    described_class.filter_preloads(node, preload_conf)
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