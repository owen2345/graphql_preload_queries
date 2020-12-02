# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :users, [UserType], null: false
    def users
      data = User.all
      include_gql_preloads(:users, data) # preloading associations
    end

    field :user, UserType, null: true do
      argument :id, ID, required: true
    end
    def user(id:)
      User.find(id) # without preloading associations
    end
  end
end
