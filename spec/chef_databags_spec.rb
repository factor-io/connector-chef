require 'spec_helper'

describe ChefConnectorDefinition do
  describe :databag do
    before do
      # @service_instance = service_instance('chef_databags')
      # @databag_name = "databag-#{SecureRandom.hex(4)}"
      # @databag = chef.data_bags.create name: @databag_name
      keep_trying do
        @databag = chef.data_bags.create name: "test-databag-#{SecureRandom.hex(4)}"
      end
      @databag_fields = [:name]
    end

    after do
      @databag.destroy if @databag
    end

    it :create do
      databag_name = "databag-#{SecureRandom.hex(4)}"
      content = test_call([:databag,:create],name:databag_name)
      expect(content).to be_a(Hash)
      expect(content).to include(:name)
      keep_trying { chef.data_bags.fetch(databag_name).destroy }
    end

    it :all do
      content = test_call([:databag,:all])
      
      expect(content).to be_a(Array)
      
      expect(content.length).to be > 0
      found_databag = content.find{|c| c[:name]==@databag.name}
      expect(found_databag).not_to be_nil

      content.each do |databag|
        expect(databag).to be_a(Hash)
        expect(databag.keys).to eq(@databag_fields)
      end
    end

    it :get do
      content = test_call([:databag,:get],id:@databag.id)
      
      expect(content).to be_a(Hash)
      expect(content).to include(:name)
      expect(content[:name]).to eq(@databag.name)
    end

    it :delete do
      content = test_call([:databag,:delete],id:@databag.name)
      
      found_databag = chef.data_bags.fetch(@databag.name)
      expect(found_databag).to be_nil
    end

    it :update do
      new_name = "test-#{SecureRandom.hex(4)}"
      content = test_call([:databag,:update],id:@databag.name,name:new_name)

      expect(content).to be_a(Hash)
      expect(content).to include(:name)
      expect(content[:name]).to eq(new_name)
    end
  end
end