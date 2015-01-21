require 'spec_helper'

describe 'chef' do
  describe ':: environments' do
    before do
      @service_instance = service_instance('chef_environments')
    end

    it ':: all' do
      @service_instance.test_action('all',@params) do
        content = expect_return[:payload]
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
    end

    it ':: get' do
      params = @params.merge({'id'=>'_default'})

      @service_instance.test_action('get',params) do
        content = expect_return[:payload]
        expect(content).to be_a(Hash)
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
    end
  end
end