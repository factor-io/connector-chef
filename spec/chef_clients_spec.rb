require 'spec_helper'

describe 'chef' do
  describe ':: clients' do
    before do
      @service_instance = service_instance('chef_clients')
      @client = chef.clients.create name: 'my-test-client'
    end

    after do
      chef.clients.fetch('my-test-client').destroy
    end

    it ':: all' do

      @service_instance.test_action('all',@params) do
        content = expect_return[:payload]
        expect(content).to be_a(Array)
        
        expect(content.length).to be > 0
        found_client = content.find{|c| c[:name]=='my-test-client'}
        expect(found_client).not_to be_nil

        content.each do |client|
          expect(client).to be_a(Hash)
          expect(client).to include(:name)
          expect(client).to include(:admin)
          expect(client).to include(:public_key)
          expect(client).to include(:private_key)
          expect(client).to include(:validator)
        end
      end
    end


    it ':: get' do
      params = @params.merge('id'=>@client.name)

      @service_instance.test_action('get',params) do
        content = expect_return[:payload]
        expect(content).to be_a(Hash)
        expect(content).to include(:name)
        expect(content).to include(:admin)
        expect(content).to include(:public_key)
        expect(content).to include(:private_key)
        expect(content).to include(:validator)
      end
    end

    it ':: create' do
      client_name = "test-#{SecureRandom.hex(4)}"
      params = @params.merge('name'=>client_name)
      @service_instance.test_action('create',params) do
        content = expect_return[:payload]
        expect(content).to be_a(Hash)
        expect(content).to include(:name)
        expect(content[:name]).to eq(client_name)
        expect(content).to include(:admin)
        expect(content).to include(:public_key)
        expect(content).to include(:private_key)
        expect(content).to include(:validator)
      end
      chef.clients.fetch(client_name).destroy
    end
  end
end