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

    context '#creation' do

      it 'creates an empty Catalog when no arguments are given' do
        catalog = Catalog.new
        catalog.should be_empty
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

        it 'creates a Catalog from a Hash' do
          catalog = Catalog.from_hash(hash_sample)
          catalog.size.should eq 9

          catalog = Catalog.from_hash(:one => 1, :two => 2, :three => 3)
          catalog.size.should eq 3
        end

        it 'creates an empty Catalog from an empty Hash' do
          catalog = Catalog.from_hash({})
          catalog.should be_empty
        end

        it 'creates a Catalog when given a Hash and a block' do
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
      pending
    end

    context '#[]' do
      pending
    end

    context '#[]=' do
      pending
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

  end
end
