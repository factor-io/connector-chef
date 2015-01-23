require 'spec_helper'

describe 'chef' do
  describe ':: databags' do
    before do
      @service_instance = service_instance('chef_databags')
      @databag_name = "databag-#{SecureRandom.hex(4)}"
      items = [
        {id:'item1', foo:'bar'},
        {id:'item2', foo:'baz'}
      ]
      @databag = chef.data_bags.create name: @databag_name
      items.each do |item|
        @databag.items.create item
      end
    end

    after do
      databag = chef.data_bags.fetch(@databag_name)
      databag.destroy if databag
    end

    it ':: create_item' do
      item_id = "item-#{SecureRandom.hex(4)}"
      data    = {'some'=>{'data'=>'here'}}
      params  = @params.merge('databag'=>@databag_name, 'id'=>item_id, 'data'=>data)

      @service_instance.test_action('create_item',params) do
        expect_return
      end

      data_bag     = chef.data_bags.fetch(@databag_name)
      created_item = data_bag.items.fetch(item_id)

      expect(created_item.id).to eq(item_id)
      expect(created_item.data).to eq(data)
    end

    it ':: items' do
      params = @params.merge('id'=>@databag_name)
      @service_instance.test_action('items',params) do
        contents = expect_return[:payload]
        expect(contents).to be_a(Hash)
        expect(contents.keys.length).to eq(2)
        expect(contents.keys).to include('item1')
        expect(contents.keys).to include('item2')
        expect(contents['item1']).to eq('foo'=>'bar')
        expect(contents['item2']).to eq('foo'=>'baz')
      end
    end

    it ':: get_item' do |params|
      params = @params.merge('databag'=>@databag_name,'id'=>'item1')

      @service_instance.test_action('get_item',params) do
        contents = expect_return[:payload]
        expect(contents).to be_a(Hash)
        expect(contents['foo']).to eq('bar')
      end
    end

    it ':: delete_item' do
      params = @params.merge({'databag'=>@databag_name,'id'=>'item1'})
    
      @service_instance.test_action('delete_item',params) do
        expect_return
      end
      expect { @databag.items.fetch('item1') }.to raise_error(ChefAPI::Error::HTTPNotFound)
    end
  end
end