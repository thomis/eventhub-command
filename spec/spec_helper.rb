require "simplecov"
SimpleCov.start

require "json"
require_relative "../lib/eh"

RSpec.configure do |config|
  # create a eh command config file unless there is an existing one
  config.before(:suite) do
    config_file = File.join(Dir.home, ".eh")
    unless File.exist?(config_file)
      File.write(config_file, '{"proxies":[],"repositories":[{"url":"https://repo.com","dir":"eventhub","deploy_username":"a_user","deploy_password":"a_password","current":true}]}')
    end
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.order = :random
end
