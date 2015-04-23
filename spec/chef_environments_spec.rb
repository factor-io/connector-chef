require 'spec_helper'

describe ChefConnectorDefinition do
  describe :environment do
    before do
      # @service_instance = service_instance('chef_environments')
      # @env_name = "env-#{SecureRandom.hex(4)}"
      # @environment = chef.environments.create name: @env_name, description:"A test environment"
    end

    after do
      # env = chef.environments.fetch(@env_name)
      # env.destroy if env
    end

    it :create do
      # env_name = "test-#{SecureRandom.hex(4)}"
      # params = @params.merge({'name'=>env_name,'description'=>'A test env'})

      # @service_instance.test_action('create',params) do
      #   content = expect_return[:payload]
      #   expect(content).to be_a(Hash)
      #   expect(content).to include(:name)
      #   expect(content).to include(:description)
      #   expect(content).to include(:default_attributes)
      #   expect(content).to include(:override_attributes)
      #   expect(content).to include(:cookbook_versions)
      #   expect(content[:default_attributes]).to be_a(Hash)
      #   expect(content[:override_attributes]).to be_a(Hash)
      #   expect(content[:cookbook_versions]).to be_a(Hash)
      # end

      # chef.environments.fetch(env_name).destroy
    end

    it :all do
      # @service_instance.test_action('all',@params) do
      #   content = expect_return[:payload]
      #   expect(content).to be_a(Array)
      #   content.each do |client|
      #     expect(client).to be_a(Hash)
      #     expect(client).to include(:name)
      #     expect(client).to include(:description)
      #     expect(client).to include(:default_attributes)
      #     expect(client).to include(:override_attributes)
      #     expect(client).to include(:cookbook_versions)
      #     expect(client[:default_attributes]).to be_a(Hash)
      #     expect(client[:override_attributes]).to be_a(Hash)
      #     expect(client[:cookbook_versions]).to be_a(Hash)
      #   end
      # end
    end

    it :get do
      # params = @params.merge({'id'=>@env_name})

      # @service_instance.test_action('get',params) do
      #   content = expect_return[:payload]
      #   expect(content).to be_a(Hash)
      #   expect(content).to include(:name)
      #   expect(content).to include(:description)
      #   expect(content).to include(:default_attributes)
      #   expect(content).to include(:override_attributes)
      #   expect(content).to include(:cookbook_versions)
      #   expect(content[:default_attributes]).to be_a(Hash)
      #   expect(content[:override_attributes]).to be_a(Hash)
      #   expect(content[:cookbook_versions]).to be_a(Hash)
      # end
    end

    it :delete do
      # name = @env_name
      # params = @params.merge({'id'=>name})
    
      # @service_instance.test_action('delete',params) do
      #   expect_return
      #   found_environment = chef.environments.fetch(name)
      #   expect(found_environment).to be_nil
      # end
    end

    it :update do
      
      # params = @params.merge({'id'=> @env_name, 'default_attributes'=>{ultramobile:{um_webapp:{revision:"234234"}}}})

      # @service_instance.test_action('update',params) do
      #   content = expect_return[:payload]
      #   expect(content).to be_a(Hash)
      #   expect(content).to include(:name)
      #   expect(content).to include(:description)
      #   expect(content).to include(:default_attributes)
      #   expect(content).to include(:override_attributes)
      #   expect(content).to include(:cookbook_versions)
      #   expect(content[:default_attributes]).to be_a(Hash)
      #   expect(content[:override_attributes]).to be_a(Hash)
      #   expect(content[:cookbook_versions]).to be_a(Hash)
      #   expect(content[:default_attributes].keys).to include('ultramobile')
      #   expect(content[:default_attributes]['ultramobile'].keys).to include('um_webapp')
      #   expect(content[:default_attributes]['ultramobile']['um_webapp'].keys).to include('revision')
      #   expect(content[:default_attributes]['ultramobile']['um_webapp']['revision']).to eq('234234')
      # end
    end
  end
end