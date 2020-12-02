# frozen_string_literal: true

module Mutations
  class UsersDisable < BaseMutation
    null true
    argument :ids, [ID], required: true

    field :users, [Types::UserType], null: true
    field :errors, [String], null: true

    def resolve(ids:)
      users = User.all.where(ids)
      res = include_gql_preloads(:users, users)
      { users: res }
    end
  end
end
