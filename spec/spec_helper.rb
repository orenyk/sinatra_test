# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
ENV['RACK_ENV'] = 'test'
require_relative '../sinatra'
require 'rspec'
require 'capybara/rspec'

set :views => File.join(File.dirname(__FILE__), "..", "views")

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  # this should give us Rack test methods
  config.include Rack::Test::Methods

end

Capybara.app = Sinatra::Application.new

# will this let us post stuff?
def app
	Sinatra::Application.new
end

# will this let us test session stuff?
def session
  last_request.env['rack.session']
end