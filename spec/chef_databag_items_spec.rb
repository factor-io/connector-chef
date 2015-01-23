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
  end
end