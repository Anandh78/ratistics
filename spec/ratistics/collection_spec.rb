require 'spec_helper'

module Ratistics

  describe Collection do

    context '#collect' do

      it 'returns an empty array when given a nil sample' do
        Collection.collect(nil).should eq []
      end

      it 'returns an empty array when given an empty sample' do
        Collection.collect([]).should eq []
      end

      it 'returns an array when given a valid sample' do
        sample = [1, 2, 3, 4, 5]
        collected = Collection.collect(sample)
        collected.size.should eq sample.size
        collected.each {|item| sample.should include(item)}
        sample.each {|item| collected.should include(item)}
      end

      it 'returns an array when given a sample with a block' do
        sample = [
          {:count => 1},
          {:count => 2},
          {:count => 3}
        ]

        collected = Collection.collect(sample){|item| item[:count]}
        collected.size.should eq sample.size
        sample.each {|item| collected.should include(item.values.first)}
      end

      context 'with ActiveRecord', :ar => true do

        specify do
          Racer.connect
          sample = Racer.all

          collected = Collection.collect(sample){|r| r.age}
          collected.size.should eq sample.size
        end
      end

      context 'with Hamster' do

        specify do
          sample = Hamster.vector(1, 2, 3, 4, 5)
          collected = Collection.collect(sample)
          collected.size.should eq sample.size
          collected.each {|item| sample.should include(item)}
          sample.each {|item| collected.should include(item)}
        end
      end
    end

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
