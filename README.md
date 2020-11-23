# GraphqlPreloadQueries (In progress)
This gem helps to define all possible preloads to graphql results data and avoid the common problem "N+1 Queries". 

## Usage
  * For query data
    ```ruby
      # queries/articles.rb
      def articles
        resolve_preloads(Article.all, { allComments: :comments })
      end
    ```
    When articles query is performed and:
    * The query includes "allComments", then ```:comments``` will be automatically preloaded  
    * The query does not include "allComments", then ```:comments``` is not preloaded  
    
  * For mutation data
    ```ruby
      # mutations/articles/approve.rb
      def resolve
        affected_articles = Article.where(id: [1,2,3])
        res = resolve_preloads(affected_articles, { allComments: :comments })
        { articles => res }
      end
    ```
    When approve mutation is performed and:
    * The result articles query includes "allComments", then ```:comments``` will be automatically preloaded  
    * The result articles query does not include "allComments", then ```:comments``` is not preloaded
    
  * For types data
    ```ruby
      # types/article_type.rb
      module Types
        class ArticleType < Types::BaseObject
          preload_field :allComments, [Types::CommentType], preload: { owner: :author }, null: false
        end
      end
    ```
    When any query is retrieving an article data and:
    * The query includes ```owner``` inside ```allComments```, then ```:author``` will be automatically preloaded inside "allComments" query  
    * The query does not include ```owner```, then ```:author``` is not preloaded
  
  Complex preload settings    
  ```ruby
    # category query
    {
      'posts' =>
        [:posts,
          {
            'authors|allAuthors' => [:author, {
              address: :address
            }],
            history: :versions
          }
        ],
      'disabled_posts' => ['category_disabled_posts.post', {
        authors: :authors
      }]
    }
  ```
  * ```authors|allAuthors``` means that the preload will be added if "authors" or "allAuthors" is present in the query
  * ```category_disabled_posts.post``` means an inner preload, sample: ```posts.preload({ category_disabled_posts: :post })```
    

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
