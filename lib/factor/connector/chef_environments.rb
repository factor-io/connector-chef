require 'factor-connector-api'
require 'chef-api'
require 'deep_merge'

Factor::Connector.service 'chef_environments' do
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
      contents = chef.environments.all
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
    fail 'Environment ID (id) is required' unless id

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
      content = chef.environments.fetch(id)
    rescue => ex
      fail ex.message
    end

    fail "Environment with id '#{id}' not found" unless content

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

    available_params = %w(name description default_attributes override_attributes cookbook_versions)
    env_params = {}
    available_params.each do |param|
      env_params[param.to_sym] = params[param] if params.include?(param)
    end

    begin
      info "Creating new environment '#{env_params['name']}'"
      chef = ChefAPI::Connection.new connection_settings
      content = chef.environments.create(env_params)
    rescue => ex
      fail ex.message
    end

    action_callback content.to_hash
  end

  action 'update' do |params|
    organization = params['organization']
    chef_server  = params['chef_server']
    client_name  = params['client_name']
    key          = params['client_key']
    id           = params['id']

    fail 'Client Name (client_name) is required' unless client_name
    fail 'Private Key (client_key) is required' unless key
    fail 'Organization (organization) or Chef Server URL (chef_server) is required' unless organization || chef_server
    fail 'Organization (organization) or Chef Server URL (chef_server) is required, but not both' if organization && chef_server
    fail 'Environment ID (id) is required' unless id

    fail 'Override Attributes (override_attributes) must be a Hash' if params['override_attributes'] && !params['override_attributes'].is_a?(Hash)
    fail 'Default Attributes (default_attributes) must be a Hash' if params['default_attributes'] && !params['default_attributes'].is_a?(Hash)
    fail 'Cookbok Versions (cookbook_versions) must be a Hash' if params['cookbook_versions'] && !params['cookbook_versions'].is_a?(Hash)

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

    available_params = %w(name description)
    env_params = {}
    available_params.each do |param|
      env_params[param.to_sym] = params[param] if params.include?(param)
    end

    begin
      info "Creating new environment '#{env_params['name']}'"
      chef = ChefAPI::Connection.new connection_settings
      environment = chef.environments.update(id, env_params) if env_params != {}

      if params['default_attributes'] || params['override_attributes'] || params['cookbook_versions']
        environment = chef.environments.fetch(id)
        environment.default_attributes.deep_merge!(params['default_attributes']) if params['default_attributes']
        environment.override_attributes.deep_merge!(params['override_attributes']) if params['override_attributes']
        environment.cookbook_versions.deep_merge!(params['cookbook_versions']) if params['cookbook_versions']
        environment.save
      end
      content = chef.environments.fetch(id)
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
    fail 'Environment ID (id) is required' unless id

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
      content = chef.environments.fetch(id)
      content.destroy
    rescue => ex
      fail ex.message
    end

    action_callback
  end
end