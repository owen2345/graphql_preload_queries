# frozen_string_literal: true

module MockPreload
  def expect_preload(preloads)
    klass = GraphqlPreloadQueries::Extensions::Preload
    allow(klass).to receive(:apply_preloads).and_call_original
    expect(klass).to receive(:apply_preloads).with(anything, preloads) # rubocop:disable RSpec/MessageSpies
  end
end

RSpec.configure do |config|
  config.include MockPreload
end
