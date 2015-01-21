require 'spec_helper'

describe 'chef' do
  describe ':: knife' do
    before do
      @service_instance = service_instance('chef_knife')
    end

    it ':: bootstrap' do

      params = {
        'host' => 'root@sandbox.factor.io',
        'private_key' => File.read(File.expand_path('~/Dropbox/Factor/Dev/deployment.pem')),
        'validation_key' => File.read(File.expand_path('~/Dropbox/Factor/Dev/chef/factor-validator.pem')),
        'organization' => 'factor',
        'name' => 'node',
        'runlist' => 'recipe[learn_chef_apache2]'
      }

      @service_instance.test_action('bootstrap',params) do
        expect_info message: 'Setting up private key'
        expect_info message: 'Running setup commands'
        expect_info message: 'Uploading /etc/chef/validation.pem'
        expect_info message: 'Uploading /etc/chef/client.rb'
        expect_info message: 'Running chef bootstrap commands'
        expect_return
      end
    end
  end
end