require 'spec_helper'

module Ratistics

  describe Collection do

    context '#binary_search' do

      let(:sample) do
        [3, 5, 6, 7, 8, 11, 15, 21, 22, 28, 30, 32, 33, 34, 40].freeze
      end

      it 'returns nil for a nil sample' do
        Collection.binary_search(nil, 1).should be_nil
      end

      it 'returns nil for an empty sample' do
        Collection.binary_search([].freeze, 1).should be_nil
      end

      it 'returns the index of the item when found as [index, index]' do
        index = Collection.binary_search(sample, 11)
        index.should eq [5, 5]
      end

      it 'returns the index of the item when using a block' do
        sample = [
          {:count => 11}, 
          {:count => 12},
          {:count => 13},
          {:count => 14},
          {:count => 16},
          {:count => 17},
          {:count => 18},
          {:count => 19},
          {:count => 20},
          {:count => 21}
        ].freeze

        index = Collection.binary_search(sample, 14){|item| item[:count]}
        index.should eq [3, 3]
      end

      it 'returns the indexes above and below when not found - below, above' do
        index = Collection.binary_search(sample, 13)
        index.should eq [5, 6]
      end

      it 'returns nil and the low index when the item is out of range on the low end - [nil, low]' do
        index = Collection.binary_search(sample, 1)
        index.should eq [nil, 0]
      end

      it 'returns the high index and nil when the item is out of range on the high end - [high, nil]' do
        index = Collection.binary_search(sample, 41)
        index.should eq [14, nil]
      end

      it 'supports an :imin option for an alternate low index' do
        index = Collection.binary_search(sample, 11, :imin => 3)
        index.should eq [5, 5]

        index = Collection.binary_search(sample, 11, :imin => 10)
        index.should eq [nil, 10]
      end

      it 'supports an :imax option for an alternate high index' do
        index = Collection.binary_search(sample, 11, :imax => 10)
        index.should eq [5, 5]

        index = Collection.binary_search(sample, 11, :imax => 4)
        index.should eq [4, nil]
      end

      it 'behaves consistently when :imin equals :imax' do
        index = Collection.binary_search(sample, 3, :imin => 5, :imax => 5)
        index.should eq [nil, 5]

        index = Collection.binary_search(sample, 11, :imin => 5, :imax => 5)
        index.should eq [5, 5]

        index = Collection.binary_search(sample, 30, :imin => 5, :imax => 5)
        index.should eq [5, nil]
      end

      it 'sets :imin to zero (0) when given a negative number' do
        index = Collection.binary_search(sample, 1, :imin => -1)
        index.should eq [nil, 0]
      end

      it 'sets :imax to the uppermost index when :imax is out of range' do
        index = Collection.binary_search(sample, 41, :imax => 100)
        index.should eq [14, nil]
      end

      it 'returns nil when :imin is greater than :imax' do
        index = Collection.binary_search(sample, 1, :imin => 10, :imax => 5)
        index.should be_nil
      end

      context 'with ActiveRecord' do

        before(:all) { Racer.connect }

        specify do
          sample = Racer.where('place > 0').order('place asc')
          index = Collection.binary_search(sample, 10){|r| r.place}
          index.should eq [9, 9]
        end

      end

      context 'Hamster' do
        
        let(:list) { Hamster.list(3, 5, 6, 7, 8, 11, 15, 21, 22, 28, 30, 32, 33, 34, 40).freeze }
        let(:vector) { Hamster.vector(3, 5, 6, 7, 8, 11, 15, 21, 22, 28, 30, 32, 33, 34, 40).freeze }

        specify { Collection.binary_search(list, 11).should eq [5, 5] }

        specify { Collection.binary_search(vector, 11).should eq [5, 5] }
      end

    end

    context '#slice' do

      context 'function signature' do

        it 'raises an exception with less than two arguments' do
          lambda {
            Ratistics.slice(1)
          }.should raise_exception(ArgumentError)
        end

        it 'raises and exception with more than three arguments' do
          lambda {
            Ratistics.slice(1, 2, 3, 4)
          }.should raise_exception(ArgumentError)
        end
      end

      context 'with index' do

        it 'returns nil if the positive index is out of range' do
          sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
          Ratistics.slice(sample, 9).should be_nil
        end

        it 'returns nil if the negative index is out of range' do
          sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
          Ratistics.slice(sample, -10).should be_nil
        end

        it 'returns the element at index for a non-negative index' do
          sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
          Ratistics.slice(sample, 3).should eq 14
        end

        it 'returns the element counted backward from the end for a negative index' do
          sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
          Ratistics.slice(sample, -4).should eq 16
        end
      end

      context 'with range' do

        it 'returns nil when the positive index is out of range' do
          sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
          Ratistics.slice(sample, (9..5)).should be_nil
        end

        it 'returns nil when the index is negative' do
          sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
          Ratistics.slice(sample, (-1..5)).should be_nil
        end

        it 'returns a subarray starting at start and continuing to end' do
          sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
          Ratistics.slice(sample, (1..5)).should eq [13, 13, 14, 13, 16]
        end

        it 'returns a subarray to the end when the end is out of range' do
          sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
          Ratistics.slice(sample, (1..100)).should eq [13, 13, 14, 13, 16, 14, 21, 13]
        end
      end

      context 'with start index and length' do

        it 'returns nil when the positive index is out of range' do
          sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
          Ratistics.slice(sample, 9, 5).should be_nil
        end

        it 'returns nil when the index is negative' do
          sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
          Ratistics.slice(sample, -1, 5).should be_nil
        end

        it 'returns a subarray specified by range' do
          sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
          Ratistics.slice(sample, 2, 4).should eq [13, 14, 13, 16]
        end

        it 'returns a subarray to the end when length is out of range' do
          sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
          Ratistics.slice(sample, 2, 100).should eq [13, 14, 13, 16, 14, 21, 13]
        end
      end

    end
  end
end
