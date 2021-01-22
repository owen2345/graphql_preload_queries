# frozen_string_literal: true

require 'graphql_preload_queries/engine'
require 'graphql'
require 'graphql_preload_queries/extensions/preload'

module GraphqlPreloadQueries
  DEBUG = false
  def self.log(msg)
    puts "***GraphqlPreloadQueries: #{msg}" if DEBUG
  end
end
