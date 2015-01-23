require "codeclimate-test-reporter"
require 'rspec'
require 'factor-connector-api/test'

CodeClimate::TestReporter.start if ENV['CODECLIMATE_REPO_TOKEN'] 

Dir.glob('./lib/factor/connector/*.rb').each { |f| require f }

RSpec.configure do |c|
  c.include Factor::Connector::Test

  c.before do
    @client_name = 'factor-test'
    @organization = 'factor-test'
    @params = {
      'client_key'   => client_key,
      'validation_key' => validation_key,
      'client_name'  => @client_name,
      'organization' => @organization,
    }
  end

  def client_key_file
    File.expand_path('./factor-test.pem')
  end

  def client_key
    File.read(client_key_file)
  end

  def validation_key_file
    File.expand_path('./factor-test-validator.pem')
  end

  def validation_key
    File.read(validation_key_file)
  end

  def chef
    @connection_settings ||= {
      endpoint: 'https://api.opscode.com/organizations/factor-test',
      client:   'factor-test',
      key:      client_key_file,
    }
    @chef ||= ChefAPI::Connection.new @connection_settings
    @chef
  end
end