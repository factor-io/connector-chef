require 'factor-connector-api'
require 'chef-api'
require 'deep_merge'

Factor::Connector.service 'chef_databags' do
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
      contents = chef.data_bags.all
    rescue => ex
      fail ex.message
    end

    action_callback contents.map {|c| c.to_hash}
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
    fail 'Data Bag ID (id) is required' unless id

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
      content = chef.data_bags.fetch(id)
    rescue => ex
      fail ex.message
    end

    fail "Data Bag with id '#{id}' not found" unless content

    action_callback content.to_hash
  end

  action 'create' do |params|
    organization = params['organization']
    chef_server  = params['chef_server']
    client_name  = params['client_name']
    key          = params['client_key']
    name         = params['name']

    fail 'Client Name (client_name) is required' unless client_name
    fail 'Private Key (client_key) is required' unless key
    fail 'Organization (organization) or Chef Server URL (chef_server) is required' unless organization || chef_server
    fail 'Organization (organization) or Chef Server URL (chef_server) is required, but not both' if organization && chef_server
    fail 'New Organization Name (name) is required' unless params['name']

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
      info "Creating new environment '#{params['name']}'"
      chef = ChefAPI::Connection.new connection_settings
      content = chef.data_bags.create(name: name)
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
    fail 'Data Bag ID (id) is required' unless id

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
      content = chef.data_bags.fetch(id)
      content.destroy
    rescue => ex
      fail ex.message
    end

    action_callback
  end
end