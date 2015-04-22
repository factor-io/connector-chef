require 'factor/connector/definition'
require 'chef-api'

class ChefConnectorDefinition < Factor::Connector::Definition
  id :chef

  def init_chef(params)
    organization = params.varify(:organization, is_a:String)
    chef_server  = params.varify(:chef_server, is_a:String)
    client_name  = params.varify(:client_name, is_a:String, required:true)
    client_key   = params.varify(:client_key, is_a:String, required:true)

    fail 'Organization (:organization) or Chef Server URL (:chef_server) is required' unless organization || chef_server
    fail 'Organization (:organization) or Chef Server URL (:chef_server) is required, but not both' if organization && chef_server

    chef_server ||= "https://api.opscode.com/organizations/#{organization}"

    safe('Setting up private key', error:'Failed to setup private key') do
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
    raw = block.yield
    if raw.respond_to?(:map)
      raw.map {|c| c.to_hash}
    elsif raw.respond_to(:to_hash)
      raw.to_hash
    else
      raw
    end
  rescue => ex
    message = options[:error] || ex.message
    fail message
  end

  resource :client do
    action :all do |params|
      chef = init_chef(params)
      clients = safe('Fetching all clients') {|x| chef.clients.all }
      respond clients
    end

    action :get do |params|
      chef = init_chef(params)
      id   = params.varify(:id, required:true)
      client = safe("Getting client with id '#{id}'"){ chef.clients.fetch(id) }
      respond client
    end

    action :create do |params|
      
    end

    action :delete do |params|
      chef = init_chef(params)
      id = params.varify(:id, required:true)
      client = safe("Deleting client with id '#{id}'"){ chef.clients.fetch(id).destroy }
      respond client
    end
  end

  resource :databage do
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

  resource :knife do
    action :bootstrap do |params|
    end
  end
end