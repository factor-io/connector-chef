require 'spec_helper'

describe ChefConnectorDefinition do
  describe :databag do
    describe :item do
      before do
        keep_trying do
          @databag = chef.data_bags.create name: "test-databag-#{SecureRandom.hex(4)}"
        end

        items = [
            {id:'item1', foo:'bar'},
            {id:'item2', foo:'baz'}
          ]
          items.each do |item|
            keep_trying { @databag.items.create(item) }
          end

        @databag_fields = [:name]
      end

      after do
        @databag.destroy if @databag
      end

      it :create do
        item_id = "item-#{SecureRandom.hex(4)}"
        data    = {'some'=>{'data'=>'here'}}
        params  = @params.merge(databag:@databag.name, id:item_id, data:data)

        contents = test_call([:databag, :item, :create], params)

        data_bag     = keep_trying { chef.data_bags.fetch(@databag.name) }
        created_item = keep_trying { data_bag.items.fetch(item_id) }

        expect(created_item.id).to eq(item_id)
        expect(created_item.data).to eq(data)
      end

      it :update do
        contents = test_call([:databag, :item, :update], databag: @databag.name, id:'item1',data:{some:{data:'here'}})

        item = chef.data_bags.fetch(@databag.name).items.fetch('item1')
        expect(item.data).to eq('foo'=>'bar','some'=>{'data'=>'here'})
      end

      it :all do
        contents = test_call([:databag, :item,:all], databag: @databag.id)
      
        expect(contents).to be_a(Array)
        expect(contents.length).to eq(2)
        expect(contents).to include(id:'item1', 'foo'=>'bar')
        expect(contents).to include(id:'item2', 'foo'=>'baz')
      end

      it :get do
        contents = test_call([:databag, :item,:get], databag: @databag.id, id:'item1')
      
        expect(contents).to be_a(Hash)
        expect(contents).to eq(id:'item1', 'foo'=>'bar')
      end

      it :delete do
        contents = test_call([:databag, :item, :delete], databag: @databag.name, id:'item1')
        items = chef.data_bags.fetch(@databag.name).items.all.map{|i| i.to_hash}
        expect(items).to_not include(id:'item1','foo'=>'baz')
      end
    end
  end
end