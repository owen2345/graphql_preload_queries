require 'rails_helper'

RSpec.describe 'User queries' do
  let!(:gql) { GraphqlTest.new() }
  describe 'when preloading query result' do
    it 'preloads configured associations for query result' do
      expect_preload({ friends: [] })
      gql.query('users', 'id name friends { id }')
    end
  end

  describe 'when preloading nested values' do
    let(:step_parents) { [User.create(name: 'name')] }
    let(:parents) { [User.create(name: 'name', parents: step_parents)] }
    let(:friends) { [User.create(name: 'name', parents: parents)] }
    let!(:user) { User.create(name: 'name', friends: friends) }

    it 'preloads 1 level nested value' do
      expect_preload({ parents: [] })
      return_data = 'id name friends { id parents { id } }'
      gql.query('user', return_data, params: { id: user.id })
    end

    it 'preloads 2 level nested values' do
      expect_preload({ parents: { parents: [] } })
      return_data = 'id name friends { id parents { id parents { id } } }'
      gql.query('user', return_data, params: { id: user.id })
    end
  end
end
