
require 'rails_helper'
RSpec.describe GraphqlPreloadQueries::Extensions::Preload do
  describe 'when filtering preloads' do
    it 'supports for multiple query names' do
      node = build_node({ allUsers: [:id, :name] })
      preload_config = { 'users|allUsers' => :users }
      res = filter_preloads(node, preload_config)
      expect(res).to eql({})
    end
    it 'supports for deep preload keys'
    it 'does not apply preload if query does not include exp. preload'
    it 'applies exp. preloads if query includes exp. preloads'
  end

  private

  def filter_preloads(node, preload_conf)
    described_class.filter_preloads(node, preload_conf)
  end

  # @param data (Hash|Array)
  def build_node(data, key = 'root')
    items = [Hash, Array].include?(data.class) ? build_selections(data) : []
    OpenStruct.new(name: key, selections: items)
  end

  # @param data (Hash)
  def build_selections(data)
    data.map do |key, val|
      build_node(val, key)
    end
  end
end