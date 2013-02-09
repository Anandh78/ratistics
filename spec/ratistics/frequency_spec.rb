require 'spec_helper'

module Ratistics
  describe Probability do

    context 'construction' do

      it 'raises an exception if the sample is nil' do
        lambda {
          Frequency.new(nil)
        }.should raise_error
      end

      it 'creates an empty frequency has if the sample is empty' do
        frequency = Frequency.new([])
        frequency.distribution.should == {}
      end

      it 'creates a frequency hash for a valid sample' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze

        frequency = Frequency.new(sample)
        frequency = frequency.distribution

        frequency.count.should eq 5
        frequency[13].should eq 4
        frequency[14].should eq 2
        frequency[16].should eq 1
        frequency[18].should eq 1
        frequency[21].should eq 1
      end

      it 'creates a frequency hash when given a block' do
        sample = [
          {:count => 10},
        ].freeze

        frequency = Frequency.new(sample){|item| item[:count]}
        frequency = frequency.distribution
        frequency.should == {10 => 1}
      end

      it 'freezes the frequency distribution' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze

        frequency = Frequency.new(sample)
        lambda {
          frequency.distribution[100] = 0
        }.should raise_error
      end

      it 'works with an ActiveRecord result set', :ar => true do
        Racer.connect

        frequency = Frequency.new(Racer.all.freeze){|r| r.age }
        frequency = frequency.distribution

        frequency.count.should eq 67
        frequency[22].should eq 11
        frequency[30].should eq 47
        frequency[26].should eq 39
        frequency[25].should eq 28
        frequency[27].should eq 50
      end

      it 'works with Hamster' do

        sample = Hamster.vector(13, 18, 13, 14, 13, 16, 14, 21, 13).freeze

        frequency = Frequency.new(sample)
        frequency = frequency.distribution

        frequency.count.should eq 5
        frequency[13].should eq 4
        frequency[14].should eq 2
        frequency[16].should eq 1
        frequency[18].should eq 1
        frequency[21].should eq 1
      end
    end

    context '#frequency_mean' do

      it 'calculates the mean of a sample' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze
        frequency = Frequency.new(sample)
        mean = frequency.frequency_mean
        mean.should be_within(0.01).of(15.0)
      end

      it 'calculates the mean when constructed with a block' do
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

        frequency = Frequency.new(sample){|item| item[:count] }
        mean = frequency.frequency_mean
        mean.should be_within(0.01).of(15.0)
      end
    end

    context '#probability' do

      it 'returns a probability hash' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze

        frequency = Frequency.new(sample)
        probability = frequency.probability

        probability.count.should eq 5
        probability[13].should be_within(0.01).of(0.444)
        probability[14].should be_within(0.01).of(0.222)
        probability[16].should be_within(0.01).of(0.111)
        probability[18].should be_within(0.01).of(0.111)
        probability[21].should be_within(0.01).of(0.111)
      end

      it 'returns a probability hash when constructed with a block' do
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

        frequency = Frequency.new(sample){|item| item[:count]}
        probability = frequency.probability

        probability.count.should eq 5
        probability[13].should be_within(0.01).of(0.444)
        probability[14].should be_within(0.01).of(0.222)
        probability[16].should be_within(0.01).of(0.111)
        probability[18].should be_within(0.01).of(0.111)
        probability[21].should be_within(0.01).of(0.111)
      end

      it 'freezes the probability' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze
        frequency = Frequency.new(sample)
        lambda {
          frequency.probability[100] = 100
        }.should raise_error
      end
    end

    context '#probability_mean' do

      it 'calculates the mean' do
        sample = [1, 2, 3, 4, 5, 6, 6, 6, 6, 6].freeze
        frequency = Frequency.new(sample)
        mean = frequency.probability_mean
        mean.should be_within(0.01).of(4.5)
      end

      it 'calculates the mean when constructed with a block' do
        sample = [
          {:count => 1},
          {:count => 2},
          {:count => 3},
          {:count => 4},
          {:count => 5},
          {:count => 6},
          {:count => 6},
          {:count => 6},
          {:count => 6},
          {:count => 6},
        ].freeze

        frequency = Frequency.new(sample){|item| item[:count]}
        mean = frequency.probability_mean
        mean.should be_within(0.01).of(4.5)
      end
    end

    context '#probability_variance' do

      it 'calculates the probability variance' do
        sample = [1, 2, 3, 4, 5, 6, 6, 6, 6, 6].freeze
        frequency = Frequency.new(sample)
        variance = frequency.probability_variance
        variance.should be_within(0.01).of(3.25)
      end

      it 'calculates the variance when constructed with a block' do
        sample = [
          {:count => 1},
          {:count => 2},
          {:count => 3},
          {:count => 4},
          {:count => 5},
          {:count => 6},
          {:count => 6},
          {:count => 6},
          {:count => 6},
          {:count => 6},
        ].freeze

        frequency = Frequency.new(sample){|item| item[:count]}
        variance = frequency.probability_variance
        variance.should be_within(0.01).of(3.25)
      end
    end

  end
end
