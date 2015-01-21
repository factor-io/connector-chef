require 'spec_helper'

describe 'chef' do
  describe ':: knife' do
    before do
      @service_instance = service_instance('chef_knife')
    end

    if ENV['CHEF_TEST_HOST'] && ENV['CHEF_TEST_NAME'] && ENV['CHEF_TEST_RUNLIST']

      it ':: bootstrap' do

        bootstrap_params = {
          'host'    => ENV['CHEF_TEST_HOST'],
          'name'    => ENV['CHEF_TEST_NAME'],
          'runlist' => ENV['CHEF_TEST_RUNLIST']
        }

        params = @params.merge(bootstrap_params)

        @service_instance.test_action('bootstrap',params) do
          expect_return
        end
      end
    end
  end
end