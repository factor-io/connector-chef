require 'spec_helper'

describe ChefConnectorDefinition do
  describe :client do
    before do
      @client = chef.clients.create name: "test-client-#{SecureRandom.hex(4)}"
      @client_fields = [:name, :admin, :public_key, :private_key, :validator]
    end

    after do
      @client.destroy
    end

    it :all do
      @runtime.run([:client,:all], @params)
      expect(@runtime).to respond

      content = @runtime.logs.last[:data]
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
      params = @params.merge(id: @client.name)

      @runtime.run([:client,:get], params)
      expect(@runtime).to respond
      content = @runtime.logs.last[:data]

      expect(content).to be_a(Hash)
      expect(content.keys).to eq(@client_fields)
    end

    it :create do
      client_name = "test-#{SecureRandom.hex(4)}"
      params = @params.merge(name:client_name)
      @runtime.run([:client,:create], params)

      expect(@runtime).to respond

      content = @runtime.logs.last[:data]
      
      expect(content).to be_a(Hash)
      expect(content.keys).to eq(@client_fields)
      expect(content[:name]).to eq(client_name)

      chef.clients.fetch(client_name).destroy
    end

    it :delete do
      params = @params.merge(id: @client.name)

      @runtime.run([:client,:delete], params)
      expect(@runtime).to respond
      
      found_client = chef.clients.fetch(@client.name)
      expect(found_client).to be_nil
    end
  end
end