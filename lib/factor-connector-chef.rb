require 'factor/connector/definition'
require 'chef-api'
require 'deep_merge'
require 'tempfile'

class ChefConnectorDefinition < Factor::Connector::Definition
  id :chef

  def init_chef(params)
    organization = params.varify(:organization, is_a:String)
    chef_server  = params.varify(:chef_server, is_a:String)
    client_name  = params.varify(:client_name, is_a:String, required:true)
    client_key   = params.varify(:client_key, is_a:String, required:true)
    private_key_file = nil

    fail 'Organization (:organization) or Chef Server URL (:chef_server) is required' unless organization || chef_server
    fail 'Organization (:organization) or Chef Server URL (:chef_server) is required, but not both' if organization && chef_server

    chef_server ||= "https://api.opscode.com/organizations/#{organization}"

    # safe('Setting up private key', error:'Failed to setup private key') do
    safe('Setting up private key') do
      private_key_file = Tempfile.new('private')
      private_key_file.write(client_key)
      private_key_file.close
    end

    connection_settings = {
      endpoint: chef_server,
      client:   client_name,
      key:      private_key_file.path,
    }
    client = ChefAPI::Connection.new connection_settings
    client
  end

  def safe(text, options={}, &block)
    info text
    raw = keep_trying { block.yield }
    if raw.respond_to?(:map)
      raw.map {|c| c.to_hash}
    elsif raw.respond_to?(:to_hash)
      raw.to_hash
    else
      raw
    end
  rescue => ex
    message = options[:error] || ex.message
    fail message
  end

  def pull_options(params,keys=[])
    available_params = keys
    extracted_params = {name:name}
    available_params.map{|p| p.to_sym}.each do |param|
      extracted_params[param] = params[param] if params.keys{|k| k.to_sym}.include?(param)
    end
    extracted_params
  end

  def keep_trying(options={},&block)
    tries = options[:tries] || 10
    begin
      block.yield
    rescue => ex
      tries -= 1
      if tries > 0
        sleep 5
        retry
      else
        raise ex
      end
    end
  end

  resource :client do
    action :all do |params|
      chef = init_chef(params)
      respond safe('Fetching all clients') {|x| chef.clients.all }
    end

    action :get do |params|
      chef = init_chef(params)
      id   = params.varify(:id, required:true)
      respond safe("Getting client with id '#{id}'"){ chef.clients.fetch(id) }
    end

    action :create do |params|
      chef = init_chef(params)
      name = params.varify(:name, is_a:String, required:true)
      
      available_params = %w(admin public_key private_key validator)
      client_params = {name:name}.marge(pull_params(params,available_params))

      respond safe("Getting client with id '#{id}'"){ chef.clients.create(client_params) }
    end

    action :delete do |params|
      chef = init_chef(params)
      id   = params.varify(:id, required:true)
      respond safe("Deleting client with id '#{id}'"){ chef.clients.fetch(id).destroy }
    end
  end

  resource :databag do
    action :all do |params|
      chef = init_chef(params)
      respond safe('Fetching all data bags') {|x| chef.data_bags.all }
    end

    action :get do |params|
      chef = init_chef(params)
      id   = params.varify(:id, required:true)
      respond safe("Fetching data bags with id '#{id}'") {|x| chef.data_bags.fetch(id) }
    end

    action :create do |params|
      chef = init_chef(params)
      name = params.varify(:name, is_a:String, required:true)
      
      respond safe("Getting client with id '#{id}'"){ chef.data_bags.create(name:name) }
    end

    action :update do |params|
      chef = init_chef(params)
      id   = params.varify(:id, required:true)
      name = params.varify(:name, is_a:String, required:true)
      
      respond safe("Fetching data bags with id '#{id}'") {|x| chef.data_bags.update(id,name:name) }
    end

    action :delete do |params|
      chef = init_chef(params)
      id = params.varify(:id, required:true)
      
      respond safe("Deleting data bag with id '#{id}'"){ chef.data_bags.fetch(id).destroy }
    end

    resource :item do
      action :all do |params|
      end

      action :get do |params|
      end

      action :create do |params|
      end

      action :update do |params|
      end

      action :delete do |params|
      end
    end
  end

  resource :environment do
    action :all do |params|
      chef = init_chef(params)
      respond safe('Fetching all environments') {|x| chef.environments.all }
    end

    action :get do |params|
      chef = init_chef(params)
      id   = params.varify(:id, required:true)
      respond safe("Fetching environments with id '#{id}'") {|x| chef.environments.fetch(id) }
    end

    action :create do |params|
      chef = init_chef(params)
      name = params.varify(:name, is_a:String, required:true)
      description = params.varify(:description, is_a:String, required:true)
      
      available_params = %w(default_attributes override_attributes cookbook_versions)
      env_params = {name: name, description: description}.merge(pull_params(params,available_params))

      respond safe("Getting client with id '#{id}'"){ chef.environments.create(env_params) }
    end

    action :update do |params|
      chef = init_chef(params)
      id   = params.varify(:id, required:true)
      name = params.varify(:name, is_a:String)
      description = params.varify(:description, is_a:String)
      
      available_params = %w(name description default_attributes override_attributes cookbook_versions)
      env_params = pull_params(params,available_params)

      respond safe("Fetching environments with id '#{id}'") {|x| chef.environments.update(id,env_params) }
    end

    action :delete do |params|
      chef = init_chef(params)
      id   = params.varify(:id, required:true)
      respond safe("Deleting environment with id '#{id}'"){ chef.environments.fetch(id).destroy }
    end
  end

  resource :knife do
    action :bootstrap do |params|
    end
  end
end