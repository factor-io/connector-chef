require 'spec_helper'

describe 'chef' do
  describe ':: databags' do
    before do
      @service_instance = service_instance('chef_databags')
      @databag_name = "databag-#{SecureRandom.hex(4)}"
      @databag = chef.data_bags.create name: @databag_name
    end

    after do
      databag = chef.data_bags.fetch(@databag_name)
      databag.destroy if databag
    end

    it ':: create' do
      databag_name = "databag-#{SecureRandom.hex(4)}"
      params = @params.merge('name'=>databag_name)

      @service_instance.test_action('create',params) do
        content = expect_return[:payload]
        expect(content).to be_a(Hash)
        expect(content).to include(:name)
      end

      chef.data_bags.fetch(databag_name).destroy
    end

    it ':: all' do
      @service_instance.test_action('all',@params) do
        contents = expect_return[:payload]
        expect(contents).to be_a(Array)
        contents.each do |content|
          expect(content).to be_a(Hash)
          expect(content).to include(:name)
        end
      end
    end

    it ':: get' do
      params = @params.merge({'id'=>@databag_name})

      @service_instance.test_action('get',params) do
        content = expect_return[:payload]
        expect(content).to be_a(Hash)
        expect(content).to include(:name)
      end
    end

    it ':: delete' do
      name = @databag_name
      params = @params.merge({'id'=>name})
    
      @service_instance.test_action('delete',params) do
        expect_return
        found_databag = chef.data_bags.fetch(name)
        expect(found_databag).to be_nil
      end
    end

    it ':: update' do
      name = @databag_name
      new_name = "test-#{SecureRandom.hex(4)}"
      params = @params.merge('id'=> name, 'name'=>new_name)

      @service_instance.test_action('update',params) do
        content = expect_return[:payload]
        expect(content).to be_a(Hash)
        expect(content).to include(:name)
        expect(content[:name]).to eq(new_name)
      end
    end
  end
end