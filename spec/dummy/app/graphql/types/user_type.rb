# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    field :id, Int, null: true
    field :name, String, null: true

    preload_field :friends, [Types::UserType], null: false,
                                               preload: { parents: [:parents, { parents: :parents }] }
    preload_field :parents, [Types::UserType], null: false,
                                               preload: { friends: :friends }
  end
end
