require 'spec_helper'

module Ratistics

  describe Collection do

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
