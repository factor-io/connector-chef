require 'factor-connector-api'
require 'chef-api'

Factor::Connector.service 'chef_clients' do
  action 'all' do |params|
    organization = params['organization']
    chef_server  = params['chef_server']
    client_name  = params['client_name']
    client_key   = params['client_key']

    fail 'Client Name (client_name) is required' unless client_name
    fail 'Client Private Key (client_key) is required' unless client_key
    fail 'Organization (organization) or Chef Server URL (chef_server) is required' unless organization || chef_server
    fail 'Organization (organization) or Chef Server URL (chef_server) is required, but not both' if organization && chef_server

    chef_server ||= "https://api.opscode.com/organizations/#{organization}"

    info 'Setting up private key'
    begin
      private_key_file = Tempfile.new('private')
      private_key_file.write(client_key)
      private_key_file.close
    rescue
      fail 'Failed to setup private key'
    end

    connection_settings = {
      endpoint: chef_server,
      client:   client_name,
      key:      private_key_file.path,
    }

    begin
      chef = ChefAPI::Connection.new connection_settings
      clients = chef.clients.all
    rescue
      fail "Couldn't get list of clients, check your credentials"
    end

    action_callback clients.map {|c| c.to_hash}
  end

  action 'get' do |params|
    organization = params['organization']
    chef_server  = params['chef_server']
    client_name  = params['client_name']
    key          = params['client_key']
    id           = params['id']

    fail 'Client Name (client_name) is required' unless client_name
    fail 'Private Key (client_key) is required' unless key
    fail 'Organization (organization) or Chef Server URL (chef_server) is required' unless organization || chef_server
    fail 'Organization (organization) or Chef Server URL (chef_server) is required, but not both' if organization && chef_server
    fail 'Client ID (id) is required' unless id

    chef_server ||= "https://api.opscode.com/organizations/#{organization}"

    info 'Setting up private key'
    begin
      private_key_file = Tempfile.new('private')
      private_key_file.write(key)
      private_key_file.close
    rescue
      fail 'Failed to setup private key'
    end

    connection_settings = {
      endpoint: chef_server,
      client:   client_name,
      key:      private_key_file.path,
    }

    begin
      chef = ChefAPI::Connection.new connection_settings
      content = chef.clients.fetch(id)
    rescue
      fail "Couldn't get list of clients, check your credentials"
    end

    fail "Client with id '#{id}' not found" unless content

    action_callback content.to_hash
  end
end