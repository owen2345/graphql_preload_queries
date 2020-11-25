# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :users_disable, mutation: Mutations::UsersDisable
  end
end
