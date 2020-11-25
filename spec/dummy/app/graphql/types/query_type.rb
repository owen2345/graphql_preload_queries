module Types
  class QueryType < Types::BaseObject

    field :users, [UserType], null: false
    def users
      resolve_preloads(User.all, { friends: :friends })
    end

    field :user, UserType, null: true do
      argument :id, ID, required: true
    end
    def user(id:)
      User.find(id)
    end
  end
end
