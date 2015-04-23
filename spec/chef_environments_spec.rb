require 'spec_helper'

describe ChefConnectorDefinition do
  describe :environment do
    before do
      keep_trying do
        @environment = chef.environments.create name: "test-environment-#{SecureRandom.hex(4)}", description: 'A test environment'
      end
      @environment_fields = [:name]
    end

    after do
      @environment.destroy if @environment
    end

    it :create do
      environment_name = "environment-#{SecureRandom.hex(4)}"
      content = test_call([:environment,:create],name:environment_name,description:'A test environment',default_attributes:{foo:'bar'})
      
      expect(content).to be_a(Hash)
      expect(content).to include(:name)
      expect(content).to include(:description)
      expect(content).to include(:default_attributes)
      expect(content).to include(:override_attributes)
      expect(content).to include(:cookbook_versions)
      expect(content[:default_attributes]).to be_a(Hash)
      expect(content[:override_attributes]).to be_a(Hash)
      expect(content[:cookbook_versions]).to be_a(Hash)

      expect(content[:default_attributes].keys).to include(:foo)
      expect(content[:default_attributes][:foo]).to eq('bar')

      keep_trying { chef.environments.fetch(environment_name).destroy }
    end

    it :all do
      content = test_call([:environment,:all])
      
      expect(content).to be_a(Array)
      
      expect(content.length).to be > 0
      found_environment = content.find{|c| c[:name]==@environment.name}
      expect(found_environment).not_to be_nil

      expect(content).to be_a(Array)
      content.each do |client|
        expect(client).to be_a(Hash)
        expect(client).to include(:name)
        expect(client).to include(:description)
        expect(client).to include(:default_attributes)
        expect(client).to include(:override_attributes)
        expect(client).to include(:cookbook_versions)
        expect(client[:default_attributes]).to be_a(Hash)
        expect(client[:override_attributes]).to be_a(Hash)
        expect(client[:cookbook_versions]).to be_a(Hash)
      end
    end

    it :get do
      content = test_call([:environment,:get],id:@environment.id)
      
      expect(content).to be_a(Hash)
      expect(content).to include(:name)
      expect(content).to include(:description)
      expect(content).to include(:default_attributes)
      expect(content).to include(:override_attributes)
      expect(content).to include(:cookbook_versions)
      expect(content[:default_attributes]).to be_a(Hash)
      expect(content[:override_attributes]).to be_a(Hash)
      expect(content[:cookbook_versions]).to be_a(Hash)
    end

    it :delete do
      content = test_call([:environment,:delete],id:@environment.name)
      
      found_environment = chef.environments.fetch(@environment.name)
      expect(found_environment).to be_nil
    end

    it :update do
      new_name = "test-#{SecureRandom.hex(4)}"
      updates = {
        name:new_name,
        default_attributes: {
          ultramobile:{
            um_webapp:{
              revision:"234234"
            }
          }
        }
      }
      content = test_call([:environment,:update],updates.merge(id:@environment.name))

      expect(content).to be_a(Hash)
      expect(content).to include(:name)
      expect(content).to include(:description)
      expect(content).to include(:default_attributes)
      expect(content).to include(:override_attributes)
      expect(content).to include(:cookbook_versions)
      expect(content[:default_attributes]).to be_a(Hash)
      expect(content[:override_attributes]).to be_a(Hash)
      expect(content[:cookbook_versions]).to be_a(Hash)
      expect(content[:default_attributes].keys).to include(:ultramobile)
      expect(content[:default_attributes][:ultramobile].keys).to include(:um_webapp)
      expect(content[:default_attributes][:ultramobile][:um_webapp].keys).to include(:revision)
      expect(content[:default_attributes][:ultramobile][:um_webapp][:revision]).to eq('234234')
    end
  end
end