require 'spec_helper'

describe 'chef' do
  describe ':: clients' do
    before do
      @service_instance = service_instance('chef_clients')
    end

    it ':: all' do
      params = {
        'client_key'   => File.read(File.expand_path('~/Dropbox/Factor/Dev/chef/skierkowski.pem')),
        'client_name'  => 'skierkowski',
        'organization' => 'factor'
      }

      @service_instance.test_action('all',params) do
        content = expect_return[:payload]
        expect(content).to be_a(Array)
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
      params = {
        'client_key'   => File.read(File.expand_path('~/Dropbox/Factor/Dev/chef/skierkowski.pem')),
        'client_name'  => 'skierkowski',
        'organization' => 'factor',
        'id'           => 'rackspace-console-dfw-02'
      }

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
  end
end