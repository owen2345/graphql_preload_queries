# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    friends_preload = { parents: { preload: :parents, parents: :parents, friends: :friends } }
    parents_preload = { preload: :parents, friends: :friends, parents: :parents }
    field :id, Int, null: true
    field :name, String, null: true
    field :friends, [Types::UserType], null: false, preload: friends_preload
    field :parents, [Types::UserType], null: false, preload: parents_preload
  end
end
