require 'spec_helper'

module Ratistics

  class LengthTester
    def initialize(*args)
      @data = args.flatten
    end
    def each(&block)
      @data.each do |datum|
        yield(datum)
      end
    end
  end

  describe Aggregates do

    context '#initialize' do

      it 'requires at least one argument' do
        lambda {
          Aggregates.new
        }.should raise_exception
      end

      it 'can be initialized from an Array' do
        sample = [1, 2, 3, 4, 5, 6].freeze
        lambda {
          Aggregates.new(sample)
        }.should_not raise_exception
      end

      it 'can be initialized from multiple arguments' do
        lambda {
          Aggregates.new(1, 2, 3, 4, 5, 6)
        }.should_not raise_exception
      end

      it 'can be initialized with a block' do
        sample = [
          {:count => 1},
          {:count => 2},
          {:count => 3}
        ].freeze
        lambda {
          Aggregates.new(sample){|item| item[:count]}
        }.should_not raise_exception
      end

      it 'can be initialized from an ActiveRecord result set' do
        Racer.connect
        sample = Racer.where('age = 40')
        lambda {
          Aggregates.new(sample){|r| r.age}
        }.should_not raise_exception
      end

      it 'can be initialized from a Hamster::Vector' do
        sample = Hamster.vector(1, 2, 3, 4, 5, 6).freeze
        lambda {
          Aggregates.new(sample)
        }.should_not raise_exception
      end
    end

    context '#length' do

      it 'returns the length of the aggregated data set' do
        Aggregates.new(1, 2, 3).length.should eq 3
      end
    end

    context '#count' do

      it 'returns #length when no arguments are given' do
        Aggregates.new(1, 2, 3, 4, 5).count.should eq 5
      end

      it 'counts the sample when it does not respond to :length' do
        sample = LengthTester.new(1, 2, 3, 4, 5)
        Aggregates.new(sample).count.should eq 5
      end

      it 'counts the elements of the given value when given an argument' do
        ag = Aggregates.new(1, 2, 2, 2, 3, 4, 5, 6, 7)
        ag.count(0).should eq 0
        ag.count(1).should eq 1
        ag.count(2).should eq 3
      end

      it 'counts the elements for which the given block is true' do
        ag = Aggregates.new(1, 2, 2, 2, 3, 4, 5, 6, 7)
        ag.count{|item| item > 2}.should eq 5
      end

      it 'prioritizes the item argument over a block' do
        ag = Aggregates.new(1, 2, 2, 2, 3, 4, 5, 6, 7)
        ag.count(2){|item| item > 2}.should eq 3
      end

      it 'yields to the block given during initialization' do
        sample = [
          {:count => 1},
          {:count => 2},
          {:count => 2},
          {:count => 2},
          {:count => 3},
          {:count => 4}
        ].freeze

        ag = Aggregates.new(sample){|item| item[:count] }
        ag.count(2).should eq 3
      end

      it 'yields to the initializer block before the argument block' do
        sample = [
          {:count => 1},
          {:count => 2},
          {:count => 2},
          {:count => 2},
          {:count => 3},
          {:count => 4}
        ].freeze

        ag = Aggregates.new(sample){|item| item[:count] }
        ag.count{|item| item > 2}.should eq 2
      end

      it 'works with an ActiveRecord result set' do
        Racer.connect
        sample = Racer.where('age > 40')
        ag = Aggregates.new(sample){|r| r.age}

        ag.count.should eq sample.size
        ag.count(40).should eq 0
        ag.count{|item| item > 50}.should == 264
      end

      it 'works with a Hamster::Vector' do
        sample = Hamster.vector(1, 2, 3, 4, 5, 6).freeze
        ag = Aggregates.new(sample)
        ag.count.should eq sample.size
      end
    end

    context 'averages' do

      it 'calculates the mean of a sample' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze
        mean = Aggregates.new(sample).mean
        mean.should be_within(0.01).of(15.0)
      end

      it 'calculates the mean using a block' do
        sample = [
          {:count => 13},
          {:count => 18},
          {:count => 13},
          {:count => 14},
          {:count => 13},
          {:count => 16},
          {:count => 14},
          {:count => 21},
          {:count => 13},
        ].freeze

        ag = Aggregates.new(sample){|item| item[:count] }
        ag.mean.should be_within(0.01).of(15.0)
      end

      it 'calculates the truncated mean' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13, 11, 19, 19, 17, 16, 13, 12, 12, 12, 20, 11].freeze
        ag = Aggregates.new(sample)
        ag.truncated_mean(10).should be_within(0.01).of(14.625)
      end

      it 'calculates the truncated mean with a block' do
        sample = [
          {:count => 11},
          {:count => 11}, 
          {:count => 12},
          {:count => 12},
          {:count => 12},
          {:count => 13},
          {:count => 13},
          {:count => 13},
          {:count => 13},
          {:count => 13},
          {:count => 14},
          {:count => 14},
          {:count => 16},
          {:count => 16},
          {:count => 17},
          {:count => 18},
          {:count => 19},
          {:count => 19},
          {:count => 20},
          {:count => 21},
        ].freeze

        ag = Aggregates.new(sample){|item| item[:count]}
        ag.truncated_mean(10).should be_within(0.01).of(14.625)
      end

      it 'returns the correct midrange for a multi-element sample' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze
        ag = Aggregates.new(sample)
        ag.midrange.should be_within(0.01).of(17.0)
      end

      it 'calculates the midrange using a block' do
        sample = [
          {:count => 13},
          {:count => 18},
          {:count => 13},
          {:count => 14},
          {:count => 13},
          {:count => 16},
          {:count => 14},
          {:count => 21},
          {:count => 13},
        ].freeze

        ag = Aggregates.new(sample){|item| item[:count]}
        ag.midrange.should be_within(0.01).of(17.0)
      end

      it 'calculates the median' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13, 0].freeze
        ag = Aggregates.new(sample)
        ag.median.should be_within(0.01).of(13.5)
      end

      it 'calculates the median using a block' do
        sample = [
          {:count => 0},
          {:count => 13},
          {:count => 13},
          {:count => 13},
          {:count => 13},
          {:count => 14},
          {:count => 14},
          {:count => 16},
          {:count => 18},
          {:count => 21},
        ].freeze

        ag = Aggregates.new(sample) {|item| item[:count] }
        ag.median.should be_within(0.01).of(13.5)
      end

      it 'returns a mode array for a multi-modal sample' do
        sample = [1, 1, 1, 3, 3, 3, 4, 4, 4, 6, 6, 6, 9].freeze
        ag = Aggregates.new(sample)
        mode = ag.mode
        mode.count.should eq 4
        mode.should include(1)
        mode.should include(3)
        mode.should include(4)
        mode.should include(6)
      end

      it 'returns a mode array for a multimodal sample with a block' do
        sample = [
          {:count => 0},
          {:count => 1},
          {:count => 2},
          {:count => 3},
          {:count => 4},
          {:count => 1},
          {:count => 2},
          {:count => 3},
          {:count => 4},
          {:count => 5},
        ].freeze

        ag = Aggregates.new(sample) {|item| item[:count] }
        mode = ag.mode
        mode.count.should eq 4
        mode.should include(1)
        mode.should include(2)
        mode.should include(3)
        mode.should include(4)
      end
    end

  end
end
