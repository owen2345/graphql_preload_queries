# GraphqlPreloadQueries
This gem permits your graphql application to define association preloads to improve app performance by removing N+1 query issues. 

## Usage
  * Object Type
    ```ruby
    class UserType < Types::BaseObject
      field :id, Int, null: true
      field :name, String, null: true
      field :parents, [Types::UserType], null: false, preload: true
      field :friends, [Types::UserType], null: false, preload: :user_friends
    end
    ```
    
    `preload:` accepts:
    - `true`: Will use field key as the association name    
      `field :parents, ..., preload: true` will preload `parents` association
    - `Symbol`: Custom association name    
      `field :friends, ..., preload: :user_friends` will preload `user_friends` association
    - `String`: Tied associations    
      `field :excluded_friends, ..., preload: 'excluded_friends.user'` will preload `excluded_friends -> user` association
    - `Hash`: Deep preload definitions   
      `field :best_friends, ..., preload: { preload: :user_friends, parents: :parents }'`  
      * Will preload `user_friends` and `user_friends.parents` only if query includes inner definition, like `user(id: 10) { bestFriends { id parents { ... } } }`       
      * Will not preload `user_friends.parents` if query does not include inner definition, like `user(id: 10) { bestFriends { id } }`
        
    
  * Preloads in query results
    - BEFORE   
      ```ruby
        # queries/users.rb
        def users(ids:)
          users = User.where(id: ids)
        end
      ```
      Does not apply preloads to the root query.
    - AFTER
      ```ruby
        def users(ids:)
          user = include_gql_preloads(User.where(id: id))
        end
      ```
      Root query applies all defined preloads
      
    - `include_gql_preloads(collection, query_key: nil, type_klass: nil)`: Will include all preloads configured in `type_klass` (UserType) based on the gql query.
      - `collection` (ActiveRecordCollection) Query results
      - `query_key` (String | Sym, default: method name) Field result key
      - `type_klass:` (GQL TypeClass, default: calculates using query_key)
    
  * Preloads in mutation results
    ```ruby
      # mutations/users/disable.rb
      #...
      field :users, [Types::UserType], null: true  
      def resolve(ids:)
        affected_users = User.where(id: ids)
        affected_users = include_gql_preloads(affected_users, query_key: :users)
        { users: affected_users }
      end
    ```
    - `include_gql_preloads(collection, query_key: , type_klass: nil)`: Will include all preloads configured in `type_klass` (UserType) based on the gql query.
      - `collection` (ActiveRecordCollection) Query results
      - `query_key` (String | Sym) Field result key 
      - `type_klass:` (GQL TypeClass, default: calculates using query_key)
    
## Installation
Add this line to your application's Gemfile:

```ruby
gem 'graphql_preload_queries'
```

And then execute:
```bash
$ bundle install
```

Or install it yourself as:
```bash
$ gem install graphql_preload_queries
```

For debugging mode:
```
  # config/initializers/gql_preload.rb
  GraphqlPreloadQueries::DEBUG = true
```

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/owen2345/graphql_preload_queries. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
