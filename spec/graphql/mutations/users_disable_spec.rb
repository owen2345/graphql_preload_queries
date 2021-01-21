# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UsersDisable' do
  let!(:gql) { GraphqlTest.new }

  describe 'when preloading' do
    it 'preloads configured associations for mutation result' do
      u = User.create(name: 'aas')
      expect_preload({ friends: {} })
      settings = {
        params: { ids: [u.id, 2] },
        result_query: 'users { id name friends { id } }'
      }
      gql.mutation('usersDisable', settings)
    end
  end
end
