# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    add_preload :friends, { parents: { preload: :parents, parents: :parents, friends: :friends } }
    add_preload 'parents|allParents', { preload: :parents, friends: :friends, parents: :parents }

    field :id, Int, null: true
    field :name, String, null: true
    field :friends, [Types::UserType], null: false
    field :parents, [Types::UserType], null: false
  end
end
