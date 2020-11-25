# frozen_string_literal: true

module Mutations
  class UsersDisable < BaseMutation
    null true
    argument :ids, [ID], required: true

    field :users, [Types::UserType], null: true
    field :errors, [String], null: true

    def resolve(ids:)
      users = User.all.where(ids)
      res = resolve_preloads(:users, users, { friends: :friends })
      { users: res }
    end
  end
end
