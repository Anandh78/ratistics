require 'spec_helper'

module Ratistics

  class MinMaxTester
    attr_reader :data
    def initialize(*args); @data = [args].flatten; end
    def each(&block); @data.each {|item| yield(item) }; end
    def empty?; @data.empty?; end
    def first; @data.first; end
  end

  describe Functions do

    context '#delta' do

      it 'computes the delta of two positive values' do
        Functions.delta(10.5, 5.0).should be_within(0.01).of(5.5)
      end

      it 'computes the delta of two negative values' do
        Functions.delta(-10.5, -5.0).should be_within(0.01).of(5.5)
      end

      it 'computes the delta of a positive and negative value' do
        Functions.delta(10.5, -5.0).should be_within(0.01).of(15.5)
      end

      it 'computes the delta of two positive values with a block' do
        v1 = {:count => 10.5}
        v2 = {:count => 5.0}
        Functions.delta(v1, v2){|x| x[:count]}.should be_within(0.01).of(5.5)
      end

      it 'computes the delta of two negative values with a block' do
        v1 = {:count => -10.5}
        v2 = {:count => -5.0}
        Functions.delta(v1, v2){|x| x[:count]}.should be_within(0.01).of(5.5)
      end

      it 'computes the delta of a positive and negative value with a block' do
        v1 = {:count => 10.5}
        v2 = {:count => -5.0}
        Functions.delta(v1, v2){|x| x[:count]}.should be_within(0.01).of(15.5)
      end
    end

    context '#relative_risk' do

      let(:low) { 16.8 }
      let(:high) { 18.2 }

      let(:low_obj) { {:risk => 16.8} }
      let(:high_obj) { {:risk => 18.2} }

      let(:low_risk) { 0.9230769230769231 }
      let(:high_risk) { 1.0833333333333333 }

      it 'computes a relative risk less than one' do
        risk = Ratistics.relative_risk(low, high)
        risk.should be_within(0.01).of(low_risk)
      end

      it 'computes a relative risk less than one with a block' do
        risk = Ratistics.relative_risk(low_obj, high_obj){|item| item[:risk]}
        risk.should be_within(0.01).of(low_risk)
      end

      it 'computes a relative risk equal to one' do
        risk = Ratistics.relative_risk(low, low)
        risk.should be_within(0.01).of(1.0)
      end

      it 'computes a relative risk equal to one with a block' do
        risk = Ratistics.relative_risk(high_obj, high_obj){|item| item[:risk]}
        risk.should be_within(0.01).of(1.0)
      end

      it 'computes a relative risk greater than one' do
        risk = Ratistics.relative_risk(high, low)
        risk.should be_within(0.01).of(high_risk)
      end

      it 'computes a relative risk greater than one with a block' do
        risk = Ratistics.relative_risk(high_obj, low_obj){|item| item[:risk]}
        risk.should be_within(0.01).of(high_risk)
      end
    end

    context '#min' do

      it 'returns nil for a nil sample' do
        Functions.min(nil).should be_nil
      end

      it 'returns nil for an empty sample' do
        Functions.min([].freeze).should be_nil
      end

      context 'when data class has a #min function' do

        it 'returns the element for a one-element sample' do
          Functions.min([10].freeze).should eq 10
        end

        it 'returns the correct min for a multi-element sample' do
          sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
          Functions.min(sample).should eq 13
        end

        it 'returns the min with a block' do
          sample = [
            {:count => 18},
            {:count => 13},
            {:count => 13},
            {:count => 14},
            {:count => 13},
            {:count => 16},
            {:count => 14},
            {:count => 21},
            {:count => 13},
          ].freeze

          min = Functions.min(sample){|item| item[:count] }
          min.should eq 13
        end
      end

      context 'when data class does not have a #min function' do

        it 'returns the element for a one-element sample' do
          Functions.min(MinMaxTester.new(10).freeze).should eq 10
        end

        it 'returns the correct min for a multi-element sample' do
          sample = MinMaxTester.new(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze
          Functions.min(sample).should eq 13
        end

        it 'returns the min with a block' do
          sample = MinMaxTester.new(
            {:count => 18},
            {:count => 13},
            {:count => 13},
            {:count => 14},
            {:count => 13},
            {:count => 16},
            {:count => 14},
            {:count => 21},
            {:count => 13}
          ).freeze

          min = Functions.min(sample){|item| item[:count] }
          min.should eq 13
        end
      end

      context 'with ActiveRecord' do

        before(:all) { Racer.connect }

        specify do
          sample = Racer.where('age > 0')
          Functions.min(sample){|r| r.age}.should eq 10
        end
      end

      context 'with Hamster' do

        let(:list) { Hamster.list(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:vector) { Hamster.vector(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:set) { Hamster.set(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze }

        specify { Functions.min(list).should eq 13 }

        specify { Functions.min(vector).should eq 13 }

        specify { Functions.min(set).should eq 13 }
      end
    end

    context '#max' do

      it 'returns nil for a nil sample' do
        Functions.max(nil).should be_nil
      end

      it 'returns nil for an empty sample' do
        Functions.max([].freeze).should be_nil
      end

      context 'when data class has a #min function' do

        it 'returns the element for a one-element sample' do
          Functions.max([10].freeze).should eq 10
        end

        it 'returns the correct max for a multi-element sample' do
          sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
          Functions.max(sample).should eq 21
        end

        it 'returns the max with a block' do
          sample = [
            {:count => 18},
            {:count => 13},
            {:count => 13},
            {:count => 14},
            {:count => 13},
            {:count => 16},
            {:count => 14},
            {:count => 21},
            {:count => 13},
          ].freeze

          max = Functions.max(sample){|item| item[:count] }
          max.should eq 21
        end
      end

      context 'when data class does not have a #min function' do

        it 'returns the element for a one-element sample' do
          Functions.max(MinMaxTester.new(10).freeze).should eq 10
        end

        it 'returns the correct max for a multi-element sample' do
          sample = MinMaxTester.new(8, 13, 13, 14, 13, 16, 14, 21, 13).freeze
          Functions.max(sample).should eq 21
        end

        it 'returns the max with a block' do
          sample = MinMaxTester.new(
            {:count => 18},
            {:count => 13},
            {:count => 13},
            {:count => 14},
            {:count => 13},
            {:count => 16},
            {:count => 14},
            {:count => 21},
            {:count => 13}
          ).freeze

          max = Functions.max(sample){|item| item[:count] }
          max.should eq 21
        end
      end

      context 'with ActiveRecord' do

        before(:all) { Racer.connect }

        specify do
          sample = Racer.where('age > 0')
          Functions.max(sample){|r| r.age}.should eq 80
        end
      end

      context 'with Hamster' do

        let(:list) { Hamster.list(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:vector) { Hamster.vector(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:set) { Hamster.set(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze }

        specify { Functions.max(list).should eq 21 }

        specify { Functions.max(vector).should eq 21 }

        specify { Functions.max(set).should eq 21 }
      end
    end

    context '#minmax' do

      it 'returns an array with two nil elements for a nil sample' do
        Functions.minmax(nil).should eq [nil, nil]
      end

      it 'returns an array with two nil elements for an empty sample' do
        Functions.minmax([].freeze).should eq [nil, nil]
      end

      context 'when data class has a #min function' do

        it 'returns the element as min and maxfor a one-element sample' do
          Functions.minmax([10].freeze).should eq [10, 10]
        end

        it 'returns the correct min and max for a multi-element sample' do
          sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
          Functions.minmax(sample).should eq [13, 21]
        end

        it 'returns the min and max with a block' do
          sample = [
            {:count => 18},
            {:count => 13},
            {:count => 13},
            {:count => 14},
            {:count => 13},
            {:count => 16},
            {:count => 14},
            {:count => 21},
            {:count => 13},
          ].freeze

          minmax = Functions.minmax(sample){|item| item[:count] }
          minmax.should eq [13, 21]
        end
      end

      context 'when data class does not have a #min function' do

        it 'returns the element as min and maxfor a one-element sample' do
          Functions.minmax(MinMaxTester.new(10).freeze).should eq [10, 10]
        end

        it 'returns the correct min and max for a multi-element sample' do
          sample = MinMaxTester.new(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze
          Functions.minmax(sample).should eq [13, 21]
        end

        it 'returns the min and max with a block' do
          sample = MinMaxTester.new(
            {:count => 18},
            {:count => 13},
            {:count => 13},
            {:count => 14},
            {:count => 13},
            {:count => 16},
            {:count => 14},
            {:count => 21},
            {:count => 13}
          ).freeze

          minmax = Functions.minmax(sample){|item| item[:count] }
          minmax.should eq [13, 21]
        end
      end

      context 'with ActiveRecord' do

        before(:all) { Racer.connect }

        specify do
          sample = Racer.where('age > 0')
          Functions.minmax(sample){|r| r.age}.should eq [10, 80]
        end
      end

      context 'with Hamster' do

        let(:list) { Hamster.list(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:vector) { Hamster.vector(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:set) { Hamster.set(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze }

        specify { Functions.minmax(list).should eq [13, 21] }

        specify { Functions.minmax(vector).should eq [13, 21] }

        specify { Functions.minmax(set).should eq [13, 21] }
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
