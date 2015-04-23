require "codeclimate-test-reporter"
require 'rspec'
require 'factor/connector/test'
require 'factor/connector/runtime'
require 'chef-api'

CodeClimate::TestReporter.start if ENV['CODECLIMATE_REPO_TOKEN'] 



require 'factor-connector-chef'

RSpec.configure do |c|
  c.include Factor::Connector::Test

  Factor::Connector::Test.timeout = 30

  c.before do
    @client_name = 'factor-test'
    @organization = 'factor-test'
    @params = {
      client_key:     client_key,
      validation_key: validation_key,
      client_name:    @client_name,
      organization:   @organization
    }
    @runtime = Factor::Connector::Runtime.new(ChefConnectorDefinition)
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

  def test_call(path,params={})
    @runtime.run(path, @params.merge(params))
    expect(@runtime).to respond
    content = @runtime.logs.last[:data]
    content
  end

  def keep_trying(options={},&block)
    tries = options[:tries] || 10
    begin
      block.call
    rescue => ex
      tries -= 1
      if tries > 0
        retry
      else
        raise ex
      end
    end
  end
end