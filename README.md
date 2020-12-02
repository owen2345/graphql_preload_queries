# GraphqlPreloadQueries
This gem helps you to define all nested preloads to be added when required for graphql data results and avoid the common problem "N+1 Queries". 

## Usage
  * Object Type
    ```ruby
    class UserType < Types::BaseObject
      add_preload 'parents|allParents', { preload: :parents, friends: :friends, parents: :parents }
      add_preload :friends, { parents: { preload: :parents, parents: :parents, friends: :friends } }
    
      field :id, Int, null: true
      field :name, String, null: true
      field :friends, [Types::UserType], null: false
      field :parents, [Types::UserType], null: false
    end
    ```
    Examples:
    * ```add_preload(:friends)```   
      ```:friends``` association will be preloaded if query includes ```friends```, like: ```user(id: 10) { friends { ... } }```
    
    * ```add_preload(:allFriends, :friends)```   
      ```:friends``` association will be preloaded if query includes ```allFriends```, like: ```user(id: 10) { allFriends { ... } }```  
    
    * ```add_preload(:allFriends, { preload: :friends, parents: :parents })```   
      ```:preload``` key can be used to indicate the association name when defining nested preloads, like: ```user(id: 10) { allFriends { id parents { ... } } }```  
    
    * ```add_preload(:friends, { allParents: :parents })```    
      (Nested 1 lvl preloading) ```friends: :parents``` association will be preloaded if query includes ```allParents```, like: ```user(id: 10) { friends { allParents { ... } } }```  
    
    * ```add_preload(:friends, { allParents: { preload: :parents, friends: :friends } })```    
      (Nested 2 levels preloading) ```friends: { parents: :friends }``` association will be preloaded if query includes ```friends``` inside ```parents```, like: ```user(id: 10) { friends { allParents { { friends { ... } } } } }```  
    
    * ```add_preload('friends|allFriends', :friends)```    
      (Multiple gql queries) ```:friends``` association will be preloaded if query includes ```friends``` or ```allFriends```, like: ```user(id: 10) { friends { ... } }``` OR ```user(id: 10) { allFriends { ... } }```   
      
    * ```add_preload('ignoredFriends', 'ignored_friends.user')```    
      (Deep preloading) ```{ ignored_friends: :user }``` association will be preloaded if query includes ```inogredFriends```, like: ```user(id: 10) { ignoredFriends { ... } }```   
    
  * Preloads in query results
    ```ruby
      # queries/users.rb
      def user(id:)
        # includes all preloads defined in user type
        #   Sample: user(id: 10){ friends { id } }
        #     :friends will be preloaded inside "user" sql query    
        user = include_gql_preloads(:user, User.where(id: id))
        
        # does not include user type preloads (only sub query preloads will be applied)
        #   Sample: user(id: 10){ friends { id parents { ... } } }
        #     Only :parents will be preloaded inside "friends" sql query
        user = User.find(id)
      end
    ```
    - include_gql_preloads: Will preload all preloads configured in UserType based on the gql query.
    
  * Preloads in mutation results
    ```ruby
      # mutations/users/disable.rb
      #...
      field :users, [Types::UserType], null: true  
      def resolve(ids:)
        affected_users = User.where(id: ids)
        affected_users = include_gql_preloads(:users, affected_users)
        puts affected_users.first&.friends # will print preloaded friends data
        { users: affected_users }
      end
    ```
    - include_gql_preloads: Will preload all preloads configured in UserType based on the gql query.
    
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

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/owen2345/graphql_preload_queries. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
