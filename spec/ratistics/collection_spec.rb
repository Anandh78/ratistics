require 'spec_helper'

module Ratistics

  describe Collection do

    context 'predicates' do

      context '#ascending?' do

        it 'returns false for a nil sample' do
          Collection.ascending?(nil).should be_false
        end

        it 'returns true for an empty sample' do
          Collection.ascending?([].freeze).should be_true
        end

        it 'returns true for a one-element sample' do
          Collection.ascending?([100].freeze).should be_true
        end

        it 'returns true for an ascending collection' do
          Collection.ascending?([1, 2, 3, 4].freeze).should be_true
        end

        it 'returns false for a non-ascending collection' do
          Collection.ascending?([1, 3, 2, 4].freeze).should be_false
        end

        it 'returns the correct value when given a block' do
          sample = [
            {:count => 11}, 
            {:count => 12},
            {:count => 13},
            {:count => 14}
          ].freeze

          Collection.ascending?(sample){|item| item[:count]}.should be_true
        end

        context 'with ActiveRecord', :ar => true do

          before(:all) { Racer.connect }

          specify do
            sample = Racer.where('place > 0').order('place asc')
            Collection.ascending?(sample){|r| r.place}.should be_true
          end

        end

        context 'Hamster' do

          let(:list) { Hamster.list(3, 5, 6, 7, 8, 11, 15, 21, 22, 28, 30, 32, 33, 34, 40).freeze }
          let(:vector) { Hamster.vector(3, 5, 6, 7, 8, 11, 15, 21, 22, 28, 30, 32, 33, 34, 40).freeze }

          specify { Collection.ascending?(list).should be_true }

          specify { Collection.ascending?(vector).should be_true }
        end
      end

      context '#descending?' do

        it 'returns false for a nil sample' do
          Collection.descending?(nil).should be_false
        end

        it 'returns true for an empty sample' do
          Collection.descending?([].freeze).should be_true
        end

        it 'returns true for a one-element sample' do
          Collection.descending?([100].freeze).should be_true
        end

        it 'returns true for an descending collection' do
          Collection.descending?([4, 3, 2, 1].freeze).should be_true
        end

        it 'returns false for a non-descending collection' do
          Collection.descending?([1, 3, 2, 4].freeze).should be_false
        end

        it 'returns the correct value when given a block' do
          sample = [
            {:count => 21},
            {:count => 20},
            {:count => 19},
            {:count => 18}
          ].freeze

          Collection.descending?(sample){|item| item[:count]}.should be_true
        end

        context 'with ActiveRecord', :ar => true do

          before(:all) { Racer.connect }

          specify do
            sample = Racer.where('place > 0').order('place desc')
            Collection.descending?(sample){|r| r.place}.should be_true
          end

        end

        context 'Hamster' do

          let(:list) { Hamster.list(40, 34, 33, 32, 30, 28, 22, 21, 15, 11, 8, 7, 6, 5, 3).freeze }
          let(:vector) { Hamster.vector(40, 34, 33, 32, 30, 28, 22, 21, 15, 11, 8, 7, 6, 5, 3).freeze }

          specify { Collection.descending?(list).should be_true }

          specify { Collection.descending?(vector).should be_true }
        end
      end

    end

    context 'sorting' do

      context '#insertion_sort!' do

        it 'returns nil for a nil sample' do
          Collection.insertion_sort!(nil).should be_nil
        end

        it 'returns the sample when the sample is empty' do
          Collection.insertion_sort!([]).should be_empty
        end

        it 'returns the sample when the sample has one element' do
          Collection.insertion_sort!([100]).should eq [100]
        end

        it 'sorts an unsorted collection' do
          sample = [31, 37, 26, 30, 2, 30, 1, 33, 5, 14, 11, 13, 17, 35, 4]
          count = sample.count
          sorted = Collection.insertion_sort!(sample)
          Collection.ascending?(sorted).should be_true
          sorted.count.should eq count
        end

        it 'does not modify an unsorted collection' do
          sample = [1, 2, 4, 5, 11, 13, 14, 17, 26, 30, 30, 31, 33, 35, 37]
          control = sample.dup
          sorted = Collection.insertion_sort!(sample)
          sorted.should eq control
        end

        it 'it sorts a collection with a block' do
          sample = [
            {:count => 31},
            {:count => 37},
            {:count => 26},
            {:count => 30},
            {:count => 2},
            {:count => 30},
            {:count => 1}
          ]

          count = sample.count
          sorted = Collection.insertion_sort!(sample){|item| item[:count]}
          Collection.ascending?(sorted){|item| item[:count]}.should be_true
          sorted.count.should eq count
        end

        it 'performs the sort in place' do
          lambda {
            sample = [31, 37, 26, 30, 2, 30, 1, 33, 5, 14, 11, 13, 17, 35, 4].freeze
            Collection.insertion_sort!(sample)
          }.should raise_error
        end
      end

    end

    context 'searching' do

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

        context 'with ActiveRecord', :ar => true do

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

    end

    context 'partitioning' do

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
end
