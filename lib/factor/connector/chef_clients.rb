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
      info "Fetching all clients"
      chef = ChefAPI::Connection.new connection_settings
      clients = chef.clients.all
    rescue => ex
      fail ex.message
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
      info "Fetching client '#{id}'"
      chef = ChefAPI::Connection.new connection_settings
      content = chef.clients.fetch(id)
    rescue => ex
      fail ex.message
    end

    fail "Client with id '#{id}' not found" unless content

    action_callback content.to_hash
  end

  action 'create' do |params|
    organization = params['organization']
    chef_server  = params['chef_server']
    client_name  = params['client_name']
    key          = params['client_key']

    fail 'Client Name (client_name) is required' unless client_name
    fail 'Private Key (client_key) is required' unless key
    fail 'Organization (organization) or Chef Server URL (chef_server) is required' unless organization || chef_server
    fail 'Organization (organization) or Chef Server URL (chef_server) is required, but not both' if organization && chef_server
    fail 'New Client Name (name) is required' unless params['name']

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

    available_params = %w(name admin public_key private_key validator)
    client_params = {}
    available_params.each do |param|
      client_params[param.to_sym] = params[param] if params.include?(param)
    end

    begin
      info "Creating new client '#{client_params['name']}'"
      chef = ChefAPI::Connection.new connection_settings
      content = chef.clients.create(client_params)
    rescue => ex
      fail ex.message
    end

    action_callback content.to_hash
  end

  action 'delete' do |params|
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
      info "Fetching client '#{id}'"
      chef = ChefAPI::Connection.new connection_settings
      content = chef.clients.fetch(id)
      info "Destroying client '#{id}'"
      content.destroy
    rescue => ex
      fail ex.message
    end

    action_callback
  end
end