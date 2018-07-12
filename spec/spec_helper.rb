require "bundler/setup"

require "vcr"
require "pry"
require "dotenv"

require "dhl_api"

Dotenv.load

DHLApi::Client.configure do |config|
  config.account_number = ENV['DHL_ACCOUNT_NUMBER'] || "TEST_DHL_ACCOUNT_NUMBER"
  config.username = ENV['DHL_USERNAME'] || "TEST_DHL_USERNAME"
  config.password = ENV['DHL_PASSWORD'] || "TEST_DHL_PASSWORD"
  config.basic_auth_username = ENV['DHL_BASIC_AUTH_USERNAME'] || "TEST_DHL_BASIC_AUTH_USERNAME"
  config.basic_auth_password = ENV['DHL_BASIC_AUTH_PASSWORD'] || "TEST_DHL_BASIC_AUTH_PASSWORD"
  config.zt_id = ENV['DHL_ZT_ID'] || "TEST_DHL_ZT_ID"
  config.zt_password = ENV['DHL_ZT_PASSWORD'] || "TEST_DHL_ZT_PASSWORD"
  config.sandbox = false
  config.logger = Logger.new(STDOUT)
  config.logger.level = if ENV['LOGGER_LEVEL'].nil?
    1
  else
    ENV['LOGGER_LEVEL'].to_i
  end
end

VCR.configure do |c|
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.ignore_localhost                        = true
  c.cassette_library_dir                    = 'spec/support/fixtures/vcr_cassettes'
  c.allow_http_connections_when_no_cassette = true
  c.default_cassette_options                = {
    match_requests_on: [:uri],
    # record: :all,
  }

  c.filter_sensitive_data("<ACCOUNT_NUMBER>") { DHLApi::Client.config.account_number }
  c.filter_sensitive_data("<USERNAME>") { DHLApi::Client.config.username }
  c.filter_sensitive_data("<PASSWORD>") { DHLApi::Client.config.password }
  c.filter_sensitive_data("<BASIC_AUTH_USERNAME>") { DHLApi::Client.config.basic_auth_username }
  c.filter_sensitive_data("<BASIC_AUTH_PASSWORD>") { DHLApi::Client.config.basic_auth_password }
  c.filter_sensitive_data("<ZT_ID>") { DHLApi::Client.config.zt_id }
  c.filter_sensitive_data("<ZT_PASSWORD>") { DHLApi::Client.config.zt_password }
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
