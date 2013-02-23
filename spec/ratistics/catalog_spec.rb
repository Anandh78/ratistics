require 'spec_helper'

module Ratistics

  describe Catalog do

    let(:hash_sample) {
      {
        7  => 8,
        17 => 14,
        27 => 6,
        32 => 12,
        37 => 8,
        22 => 4,
        42 => 3,
        12 => 8,
        47 => 2
      }.freeze
    }

    let(:hash_sample_for_block) {
      {
        7  => {:count => 8},
        17 => {:count => 14},
        27 => {:count => 6},
        32 => {:count => 12},
        37 => {:count => 8},
        22 => {:count => 4},
        42 => {:count => 3},
        12 => {:count => 8},
        47 => {:count => 2}
      }.freeze
    }

    let(:catalog_sample) {
      [
        [7, 8],
        [17, 14],
        [27, 6],
        [32, 12],
        [37, 8],
        [22, 4],
        [42, 3],
        [12, 8],
        [47, 2]
      ].freeze
    }

    let(:catalog_sample_for_block) {
      [
        [7, {:count => 8}],
        [17, {:count => 14}],
        [27, {:count => 6}],
        [32, {:count => 12}],
        [37, {:count => 8}],
        [22, {:count => 4}],
        [42, {:count => 3}],
        [12, {:count => 8}],
        [47, {:count => 2}]
      ].freeze
    }

    context 'creation' do

      context '#initialize' do

        it 'creates an empty Catalog when no arguments are given' do
          catalog = Catalog.new
          catalog.should be_empty
        end

        it 'creates a Catalog from a hash' do
          catalog = Catalog.new(hash_sample, :from => :hash)
          catalog.size.should eq 9
        end

        it 'creates a Catalog from an array' do
          catalog = Catalog.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], :from => :array)
          catalog.size.should eq 5
          catalog.first.should eq [1, 2]
          catalog.last.should eq [9, 10]
        end

        it 'creates a Catalog from a catalog' do
          catalog = Catalog.new(catalog_sample, :from => :catalog)
          catalog.size.should eq 9
          catalog.first.should eq catalog_sample.first
          catalog.last.should eq catalog_sample.last

          catalog = Catalog.new(catalog_sample, :from => :catalogue)
          catalog.size.should eq 9
          catalog.first.should eq catalog_sample.first
          catalog.last.should eq catalog_sample.last
        end

        it 'creates an empty Catalog when :from is unrecognized' do
          catalog = Catalog.new(hash_sample, :from => :bogus)
          catalog.should be_empty
        end
      end

      context '#from_array' do

        it 'creates a Catalog from an Array' do
          catalog = Catalog.from_array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
          catalog.size.should eq 5
          catalog.first.should eq [1, 2]
          catalog.last.should eq [9, 10]

          catalog = Catalog.from_array(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
          catalog.size.should eq 5
          catalog.first.should eq [1, 2]
          catalog.last.should eq [9, 10]
        end

        it 'creates an empty Catalog from an empty Array' do
          catalog = Catalog.from_array([])
          catalog.should be_empty
        end

        it 'throws out the last element when given an odd-size array' do
          catalog = Catalog.from_array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
          catalog.size.should eq 5
          catalog.first.should eq [1, 2]
          catalog.last.should eq [9, 10]
        end

        it 'creates a Catalog when given an array and a block' do
          sample = [
            {:count => 13},
            {:count => 18},
            {:count => 13},
            {:count => 14},
            {:count => 13},
            {:count => 16},
            {:count => 14},
            {:count => 13}
          ].freeze

          catalog = Catalog.from_array(sample){|item| item[:count]}
          catalog.size.should eq 4
          catalog.first.should eq [13, 18]
          catalog.last.should eq [14, 13]
        end
      end

      context '#from_hash' do

        it 'creates a Catalog from a hash' do
          catalog = Catalog.from_hash(hash_sample)
          catalog.size.should eq 9

          catalog = Catalog.from_hash(:one => 1, :two => 2, :three => 3)
          catalog.size.should eq 3
        end

        it 'creates an empty Catalog from an empty hash' do
          catalog = Catalog.from_hash({})
          catalog.should be_empty
        end

        it 'creates a Catalog when given a hash and a block' do
          catalog = Catalog.from_hash(hash_sample_for_block){|item| item[:count]}
          catalog.size.should eq 9
        end
      end

      context '#from_catalog' do

        it 'creates a Catalog from a catalog' do
          catalog = Catalog.from_catalog(catalog_sample)
          catalog.size.should eq 9
          catalog.first.should eq catalog_sample.first
          catalog.last.should eq catalog_sample.last

          catalog = Catalog.from_catalog([:one, 1], [:two, 2], [:three, 3])
          catalog.size.should eq 3
          catalog.first.should eq [:one, 1]
          catalog.last.should eq [:three, 3]

          catalog = Catalog.from_catalog([:one, 1], [:two, 2])
          catalog.size.should eq 2
          catalog.first.should eq [:one, 1]
          catalog.last.should eq [:two, 2]

          catalog = Catalog.from_catalog([:one, 1])
          catalog.size.should eq 1
          catalog.first.should eq [:one, 1]
          catalog.last.should eq [:one, 1]
        end

        it 'creates an empty Catalog from an empty catalog' do
          catalog = Catalog.from_catalog({})
          catalog.should be_empty
        end

        it 'creates a Catalog when given a catalog and a block' do
          catalog = Catalog.from_catalog(catalog_sample_for_block){|item| item[:count]}
          catalog.size.should eq 9
          catalog.first.should eq [catalog_sample.first[0], catalog_sample.first[1]]
          catalog.last.should eq [catalog_sample.last[0], catalog_sample.last[1]]
        end
      end

      context 'with ActiveRecord', :ar => true do
        pending
      end

      context 'with Hamster' do
        pending
      end
    end

    context '#==' do
      
      it 'returns true for equal catalogs' do
        catalog_1 = Catalog.from_hash(hash_sample)
        catalog_2 = Catalog.from_hash(hash_sample)
        catalog_1.should eq catalog_2
      end

      
      it 'returns false for unequal catalogs' do
        catalog_1 = Catalog.new
        catalog_2 = Catalog.from_hash(hash_sample)
        catalog_1.should_not eq catalog_2
      end
    end

    context '#[]' do

      it 'returns nil when empty' do
        catalog = Catalog.new
        catalog[0].should be_nil
      end

      it 'returns the element at a valid positive index' do
        catalog = Catalog.from_catalog(catalog_sample)
        catalog[0].should eq catalog_sample[0]
      end

      it 'returns the element at a valid negative index' do
        catalog = Catalog.from_catalog(catalog_sample)
        catalog[-1].should eq catalog_sample[-1]
      end

      it 'returns nil for an invalid positive index' do
        catalog = Catalog.from_catalog(catalog_sample)
        catalog[100].should be_nil
      end

      it 'returns nil for an invalid negative index' do
        catalog = Catalog.from_catalog(catalog_sample)
        catalog[-100].should be_nil
      end
    end

    context '#[]=' do

      let(:catalog) { Catalog.from_hash(:one => 1, :two => 2, :three => 3) }

      it 'accepts a one-element hash as a value' do
        catalog[0] = {:foo => :bar}
        catalog[0].should eq [:foo, :bar]
      end

      it 'accepts a two-element array as a value' do
        catalog[0] = [:foo, :bar]
        catalog[0].should eq [:foo, :bar]
      end

      it 'raises an exception when given in invalid value' do
        lambda {
          catalog[0] = :foo
        }.should raise_error(ArgumentError)
      end

      it 'updates the index when given a valid positive index' do
        catalog[1] = [:foo, :bar]
        catalog.raw.should eq [[:one, 1], [:foo, :bar], [:three, 3]]
      end

      it 'updates the index when given an invalid negative index' do
        catalog[-2] = [:foo, :bar]
        catalog.raw.should eq [[:one, 1], [:foo, :bar], [:three, 3]]
      end

      it 'raises an exception when given an invalid positive index' do
        lambda {
          catalog[100] = [:foo, :bar]
        }.should raise_error(ArgumentError)
      end

      it 'raises an exception when given an invalid negative index' do
        lambda {
          catalog[-100] = [:foo, :bar]
        }.should raise_error(ArgumentError)
      end

    end

    context '#&' do
      pending
    end

    context '#+' do
      pending
    end

    context '#|' do
      pending
    end

    context '#<<' do
      pending
    end

    context '#==' do
      pending
    end

    context '#at' do
      pending
    end

    context '#keys' do
      pending
    end

    context '#values' do
      pending
    end

    context '#first' do

      it 'returns nil when empty' do
        Catalog.new.first.should be_nil
      end

      it 'returns the first element when not empty' do
        catalog = Catalog.from_catalog(catalog_sample)
        catalog.first.should == catalog_sample.first
      end
    end

    context '#last' do

      it 'returns nil when empty' do
        Catalog.new.last.should be_nil
      end

      it 'returns the last element when not empty' do
        catalog = Catalog.from_catalog(catalog_sample)
        catalog.last.should == catalog_sample.last
      end
    end

    context '#each' do
      pending
    end

    context '#each_pair' do
      pending
    end

    context '#each_key' do
      pending
    end

    context '#each_value' do
      pending
    end

    context '#each_with_index' do
      pending
    end

    context '#empty?' do

      it 'returns true when empty' do
        catalog = Catalog.new
        catalog.should be_empty
      end

      it 'returns false when not empty' do
        catalog = Catalog.from_hash(:one => 1, :two => 2, :three => 3)
        catalog.should_not be_empty
      end
    end

    context '#include?' do
      pending
    end

    context 'raw' do

      it 'returns a new, empty array when empty' do
        catalog = Catalog.new
        catalog.raw.object_id.should_not eq catalog.instance_variable_get(:@data).object_id
      end

      it 'returns a copy of the internal data when not empty' do
        catalog = Catalog.from_hash(:one => 1, :two => 2, :three => 3)
        catalog.raw.object_id.should_not eq catalog.instance_variable_get(:@data).object_id
      end
    end

    context '#size' do

      it 'returns zero when is empty' do
        catalog = Catalog.new
        catalog.size.should eq 0
      end

      it 'returns the correct positive integer when not empty' do
        catalog = Catalog.from_hash(:one => 1, :two => 2, :three => 3)
        catalog.size.should eq 3
      end
    end

    context '#slice' do
      pending
    end

    context '#slice!' do
      pending
    end

    context '#sort_by_key' do
      pending
    end

    context '#sort_by_key!' do
      pending
    end

    context '#sort_by_value' do
      pending
    end

    context '#sort_by_value!' do
      pending
    end

    context '#to_a' do
      pending
    end

    context '#to_hash' do
      pending
    end

    context '#to_catalog' do
      pending
    end

    context '#to_s' do

      specify { Catalog.new.to_s.should eq '[]' }

      specify { Catalog.from_hash(:one => 1, :two => 2).to_s.should eq '[[:one, 1], [:two, 2]]' }
    end

  end
end
