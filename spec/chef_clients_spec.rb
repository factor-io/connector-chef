require 'spec_helper'

describe ChefConnectorDefinition do
  describe :client do
    before do
      keep_trying do
        @client = chef.clients.create name: "test-client-#{SecureRandom.hex(4)}"
      end

      @client_fields = [:name, :admin, :public_key, :private_key, :validator]
    end

    after do
      keep_trying do
        @client.destroy if @client
      end
    end

    it :all do
      content = test_call([:client,:all])

      expect(content).to be_a(Array)
      
      expect(content.length).to be > 0
      found_client = content.find{|c| c[:name]==@client.name}
      expect(found_client).not_to be_nil

      content.each do |client|
        expect(client).to be_a(Hash)
        expect(client.keys).to eq(@client_fields)
      end
    end


    it :get do
      content = test_call([:client,:get],id:@client.name)

      expect(content).to be_a(Hash)
      expect(content.keys).to eq(@client_fields)
    end

    it :create do
      client_name = "test-#{SecureRandom.hex(4)}"
      content = test_call([:client,:create],name:client_name)
      
      expect(content).to be_a(Hash)
      expect(content.keys).to eq(@client_fields)
      expect(content[:name]).to eq(client_name)

      keep_trying { chef.clients.fetch(client_name).destroy }
    end

    it :delete do
      content = test_call([:client,:delete],id:@client.name)
      
      found_client = keep_trying { chef.clients.fetch(@client.name) }
      expect(found_client).to be_nil
    end
  end
end