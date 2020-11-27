# GraphqlPreloadQueries
This gem helps you to define all nested preloads to be added when required for graphql data results and avoid the common problem "N+1 Queries". 

## Usage
  * Preloads in query results
    ```ruby
      # queries/articles.rb
      def articles
        resolve_preloads(Article.all, { allComments: :comments })
      end
    ```
    When articles query is performed and:
    * The query includes "allComments", then ```:comments``` will automatically be preloaded    
      - Single query: ```articles { id comments { id msg } } ```      
      - Relay query: ```articles { nodes { id comments { id msg } } } ```  
    * The query does not include "allComments", then ```:comments``` is not preloaded    
      ```articles { id title } ```  
    
  * Preloads in mutation results
    ```ruby
      # mutations/articles/approve.rb
      #...
      field :articles, [Types::ArticleType], null: true  
      def resolve
        affected_articles = Article.where(id: [1,2,3])
        res = resolve_preloads(:articles, affected_articles, { allComments: :comments })
        { articles: res }
      end
    ```
    When approve mutation is performed and:
    * The result articles query includes "allComments", then ```:comments``` will automatically be preloaded    
      ```mutation articlesApprove (...) { articles { id allComments { id msg } } }```
    * The result articles query does not include "allComments", then ```:comments``` is not preloaded   
      ```mutation articlesApprove (...) { articles { id title } }```
    
  * Preloads in ObjectTypes
    ```ruby
      # types/article_type.rb
      module Types
        class ArticleType < Types::BaseObject
          preload_field :allComments, [Types::CommentType], preload: { owner: :author }, null: false
        end
      end
    ```
    When any query is retrieving an article data and:
    * The query includes ```owner``` inside ```allComments```, then ```:author``` will automatically be preloaded inside "allComments" query    
      ```article { id allComments { id owner { id name } } } ```
    * The query does not include ```owner```, then ```:author``` is not preloaded   
      ```article { id allComments { id msg } } ```
    Note: This field is exactly the same as the graphql field, except that this field expects for "preload" setting which contains all configurations for preloading
    
  Complex preload settings    
  ```ruby
    # category query
    {
      'posts' =>
        [:posts, # :posts preload key will be used when: { posts { id ... } }
          {
            'authors|allAuthors' => [:author, { # :author key will be used when: { posts { allAuthors { id ... } } } 
              address: :address # :address preload key will be used when: { posts { allAuthors { address { id ... } } } }
            }],
            history: :versions # :versions key will be used when: { posts { history { ... } } }
          }
        ],
      'disabledPosts' => ['category_disabled_posts.post', { # :category_disabled_posts.post key will be used when: { disabledPosts { ... } }
        authors: :authors # :authors key will be used when: { disabledPosts { authors { ... } } }
      }]
    }
  ```
  * ```authors|allAuthors``` means that the preload will be added if "authors" or "allAuthors" is present in the query
  * ```category_disabled_posts.post``` means an inner preload, sample: ```posts.preload({ category_disabled_posts: :post })```
    
### Important: 
  Is needed to omit "extra" params auto provided by Graphql when using custom resolver (only in case not using params), sample:
  ```ruby
    # types/post_type.rb
    preload_field :allComments, [Types::CommentType], preload: { owner: :author }, null: false
    def allComments(_omit_gql_params) # custom method resolver that omits non used params
      object.allComments
    end
  ```
    

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
