# frozen_string_literal: true

class GraphqlTest
  attr_accessor :context, :silence_error
  def initialize(context: {})
    @context = context
  end

  # @param query_name (String) Query name
  # @param attrs (String) Attributes to retrieve
  # @param params (Hash) Query parameters
  def query(query_name, attrs = '', params: {}, only_data: true)
    query = "{
      #{query_name} #{graphql_parse_args(params)} {
        #{attrs.presence || 'id'}
      }
    }"
    res = execute(query)
    only_data ? res[:data][query_name] : res[:data]
  end

  # @param query_name (String) Query name
  # @param attrs (String) Attributes to retrieve
  # @param params (Hash) Query parameters
  # @param info (String) Query info, sample: pageInfo { hasNextPage }
  # @param only_data (Boolean, default true) if false returns all query info
  def query_adv(query_name, attrs = '', params: {}, info: '', only_data: true)
    attrs = attrs.presence || 'node { id }'
    query = "query {
      #{query_name} #{graphql_parse_args(params)} {
        nodes { #{attrs} }
        #{info}
      }
    }".gsub("#{query_name}()", query_name.to_s) # remove empty parentheses when params is empty
    res = execute(query)[:data]
    only_data ? res[query_name][:nodes] : res[query_name]
  end

  # @param mutation_name (String): Mutation name
  # @param params (Hash): Query parameters
  # @param result_query (String): Result query
  # @param mutation_input (String): Custom mutation input
  #   (default: auto generated from mutation name)
  def mutation(mutation_name, params: {}, result_query: '', mutation_input: nil)
    mutation_input ||= "#{mutation_name.sub(/\S/, &:upcase)}Input!"
    result_query = result_query.presence || ''
    query = "mutation #{mutation_name}($input: #{mutation_input}) {
      #{mutation_name}(input: $input) {
        #{result_query}
        errors
      }
    }"
    res = execute(query, variables: { input: params })
    res.dig(:data, mutation_name) || res
  end

  private

  def execute(query, variables: {})
    settings = { context: context, variables: variables }
    res = DummySchema.execute(query, settings)
    res = res.to_h.with_indifferent_access
    if res[:errors] && !@silence_error
      error_data = { result: res, query: query, variables: variables }
      puts "\e[31m#{error_data}\e[0m"
    end
    res
  end

  # convert hash into query format:
  # @Sample: {a: 10, b: 'hi'} ==> a: 10, b: "hi"
  def graphql_parse_args(args)
    parsed_args = args.to_json.gsub(/\"(\w+)\":/, '\1:')[1..-2]
    parsed_args.present? ? "(#{parsed_args})" : ''
  end
end
