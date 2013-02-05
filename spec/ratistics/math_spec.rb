require 'spec_helper'

module Ratistics

  class MinMaxTester
    attr_reader :data
    def initialize(*args); @data = [args].flatten; end
    def each(&block); @data.each {|item| yield(item) }; end
    def empty?; @data.empty?; end
    def first; @data.first; end
  end

  describe Math do

    context '#delta' do

      it 'computes the delta of two positive values' do
        Math.delta(10.5, 5.0).should be_within(0.01).of(5.5)
      end

      it 'computes the delta of two negative values' do
        Math.delta(-10.5, -5.0).should be_within(0.01).of(5.5)
      end

      it 'computes the delta of a positive and negative value' do
        Math.delta(10.5, -5.0).should be_within(0.01).of(15.5)
      end

      it 'computes the delta of two positive values with a block' do
        v1 = {:count => 10.5}
        v2 = {:count => 5.0}
        Math.delta(v1, v2){|x| x[:count]}.should be_within(0.01).of(5.5)
      end

      it 'computes the delta of two negative values with a block' do
        v1 = {:count => -10.5}
        v2 = {:count => -5.0}
        Math.delta(v1, v2){|x| x[:count]}.should be_within(0.01).of(5.5)
      end

      it 'computes the delta of a positive and negative value with a block' do
        v1 = {:count => 10.5}
        v2 = {:count => -5.0}
        Math.delta(v1, v2){|x| x[:count]}.should be_within(0.01).of(15.5)
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
        Math.min(nil).should be_nil
      end

      it 'returns nil for an empty sample' do
        Math.min([].freeze).should be_nil
      end

      context 'when data class has a #min function' do

        it 'returns the element for a one-element sample' do
          Math.min([10].freeze).should eq 10
        end

        it 'returns the correct min for a multi-element sample' do
          sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
          Math.min(sample).should eq 13
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

          min = Math.min(sample){|item| item[:count] }
          min.should eq 13
        end
      end

      context 'when data class does not have a #min function' do

        it 'returns the element for a one-element sample' do
          Math.min(MinMaxTester.new(10).freeze).should eq 10
        end

        it 'returns the correct min for a multi-element sample' do
          sample = MinMaxTester.new(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze
          Math.min(sample).should eq 13
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

          min = Math.min(sample){|item| item[:count] }
          min.should eq 13
        end
      end

      context 'with ActiveRecord' do

        before(:all) { Racer.connect }

        specify do
          sample = Racer.where('age > 0')
          Math.min(sample){|r| r.age}.should eq 10
        end
      end

      context 'with Hamster' do

        let(:list) { Hamster.list(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:vector) { Hamster.vector(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:set) { Hamster.set(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze }

        specify { Math.min(list).should eq 13 }

        specify { Math.min(vector).should eq 13 }

        specify { Math.min(set).should eq 13 }
      end
    end

    context '#max' do

      it 'returns nil for a nil sample' do
        Math.max(nil).should be_nil
      end

      it 'returns nil for an empty sample' do
        Math.max([].freeze).should be_nil
      end

      context 'when data class has a #min function' do

        it 'returns the element for a one-element sample' do
          Math.max([10].freeze).should eq 10
        end

        it 'returns the correct max for a multi-element sample' do
          sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
          Math.max(sample).should eq 21
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

          max = Math.max(sample){|item| item[:count] }
          max.should eq 21
        end
      end

      context 'when data class does not have a #min function' do

        it 'returns the element for a one-element sample' do
          Math.max(MinMaxTester.new(10).freeze).should eq 10
        end

        it 'returns the correct max for a multi-element sample' do
          sample = MinMaxTester.new(8, 13, 13, 14, 13, 16, 14, 21, 13).freeze
          Math.max(sample).should eq 21
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

          max = Math.max(sample){|item| item[:count] }
          max.should eq 21
        end
      end

      context 'with ActiveRecord' do

        before(:all) { Racer.connect }

        specify do
          sample = Racer.where('age > 0')
          Math.max(sample){|r| r.age}.should eq 80
        end
      end

      context 'with Hamster' do

        let(:list) { Hamster.list(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:vector) { Hamster.vector(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:set) { Hamster.set(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze }

        specify { Math.max(list).should eq 21 }

        specify { Math.max(vector).should eq 21 }

        specify { Math.max(set).should eq 21 }
      end
    end

    context '#minmax' do

      it 'returns an array with two nil elements for a nil sample' do
        Math.minmax(nil).should eq [nil, nil]
      end

      it 'returns an array with two nil elements for an empty sample' do
        Math.minmax([].freeze).should eq [nil, nil]
      end

      context 'when data class has a #min function' do

        it 'returns the element as min and maxfor a one-element sample' do
          Math.minmax([10].freeze).should eq [10, 10]
        end

        it 'returns the correct min and max for a multi-element sample' do
          sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
          Math.minmax(sample).should eq [13, 21]
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

          minmax = Math.minmax(sample){|item| item[:count] }
          minmax.should eq [13, 21]
        end
      end

      context 'when data class does not have a #min function' do

        it 'returns the element as min and maxfor a one-element sample' do
          Math.minmax(MinMaxTester.new(10).freeze).should eq [10, 10]
        end

        it 'returns the correct min and max for a multi-element sample' do
          sample = MinMaxTester.new(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze
          Math.minmax(sample).should eq [13, 21]
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

          minmax = Math.minmax(sample){|item| item[:count] }
          minmax.should eq [13, 21]
        end
      end

      context 'with ActiveRecord' do

        before(:all) { Racer.connect }

        specify do
          sample = Racer.where('age > 0')
          Math.minmax(sample){|r| r.age}.should eq [10, 80]
        end
      end

      context 'with Hamster' do

        let(:list) { Hamster.list(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:vector) { Hamster.vector(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:set) { Hamster.set(18, 13, 13, 14, 13, 16, 14, 21, 13).freeze }

        specify { Math.minmax(list).should eq [13, 21] }

        specify { Math.minmax(vector).should eq [13, 21] }

        specify { Math.minmax(set).should eq [13, 21] }
      end
    end

    context 'rank calculations' do

      specify { Math.ordinal_rank(40, 5).should be_within(0.001).of(2.5) }

      specify { Math.nist_primary_rank(40, 5).should be_within(0.001).of(2.4) }

      specify { Math.nist_alternate_rank(40, 5).should be_within(0.001).of(2.6) }

    end

    context '#summation' do

      let(:sample) do
        [17, 14, 7, 8, 16, 7, 11, 10, 3, 15].freeze
      end

      it 'returns zero for a nil sample' do
        Math.summation(nil).should eq 0
      end

      it 'returns zero for an empty sample' do
        Math.summation([].freeze).should eq 0
      end

      it 'returns the value of a single-element array' do
        Math.summation([10].freeze).should eq 10
      end

      it 'sums the entire sample when no lower or upper bound is given' do
        Math.summation(sample).should eq 108
      end

      it 'sums the sample staring with the supplied lower bound' do
        Math.summation(sample, :lower => 3).should eq 70
      end

      it 'sums the sample ending with the supplied upper bound' do
        Math.summation(sample, :upper => 6).should eq 80
      end

      it 'sums the sample between the supplied upper and lower bounds' do
        Math.summation(sample, :lower => 1, :upper => 8).should eq 76
      end

      it 'returns zero when given an invalid lower bound' do
        Math.summation(sample, :lower => -1).should eq 0
      end

      it 'returns zero when given in invalid upper bound' do
        Math.summation(sample, :upper => sample.size * 2).should eq 0
      end

      it 'returns zero when the lower bound is greater than the upper bound' do
        Math.summation(sample, :lower => 4, :upper => 2).should eq 0
      end

      it 'sums the sample when given a block' do
        Math.summation((1..10).to_a){|i| i**2 }.should eq 385
      end

      context 'with ActiveRecord' do

        before(:all) { Racer.connect }

        specify do
          sample = Racer.where('age > 0').order('age asc').limit(10)
          Math.summation(sample){|r| r.age}.should eq 113
        end
      end

      context 'with Hamster' do

        let(:list) { Hamster.list(17, 14, 7, 8, 16, 7, 11, 10, 3, 15).freeze }
        let(:vector) { Hamster.vector(17, 14, 7, 8, 16, 7, 11, 10, 3, 15).freeze }

        specify { Math.summation(list).should eq 108 }

        specify { Math.summation(vector).should eq 108 }
      end
    end

  end
end
