require 'spec_helper'

module Ratistics

  describe Frequencies do

    context '#initialize' do

      it 'raises an exception if the sample is nil' do
        lambda {
          Frequencies.new(nil)
        }.should raise_error
      end

      it 'always collects the sample data' do
        sample = [1, 2, 3, 4, 5, 6].freeze
        frequency = Frequencies.new(sample)
        frequency.data.object_id.should_not eq sample.object_id
      end

      it 'creates an empty #distribution if the sample is empty' do
        frequency = Frequencies.new([])
        frequency.distribution.should == {}
      end

      it 'creates a #distribution for a valid sample array' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze

        frequency = Frequencies.new(sample)
        frequency = frequency.distribution

        frequency.count.should eq 5
        frequency[13].should eq 4
        frequency[14].should eq 2
        frequency[16].should eq 1
        frequency[18].should eq 1
        frequency[21].should eq 1
      end

      it 'creates a #distribution when given a block' do
        sample = [
          {:count => 10},
        ].freeze

        frequency = Frequencies.new(sample){|item| item[:count]}
        frequency = frequency.distribution
        frequency.should == {10 => 1}
      end

      it 'works with an ActiveRecord result set', :ar => true do
        Racer.connect

        frequency = Frequencies.new(Racer.all.freeze){|r| r.age }
        frequency = frequency.distribution

        frequency.count.should eq 67
        frequency[22].should eq 11
        frequency[30].should eq 47
        frequency[26].should eq 39
        frequency[25].should eq 28
        frequency[27].should eq 50
      end

      it 'works with Hamster', :hamster => true do

        sample = Hamster.vector(13, 18, 13, 14, 13, 16, 14, 21, 13).freeze

        frequency = Frequencies.new(sample)
        frequency = frequency.distribution

        frequency.count.should eq 5
        frequency[13].should eq 4
        frequency[14].should eq 2
        frequency[16].should eq 1
        frequency[18].should eq 1
        frequency[21].should eq 1
      end
    end

    context '#distribution' do

      let(:sample) { [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze }
      let(:frequency) { Frequencies.new(sample) }

      it 'returns a hash when the :as option is nil' do
        frequency.distribution.should be_a Hash
      end

      it 'returns a hash when the :as option is :hash' do
        frequency.distribution(:as => :hash).should be_a Hash
      end

      it 'returns an array when the :as option is :array' do
        frequency.distribution(:as => :array).should be_a Array
      end

      it 'raises an error when the :as option is unrecognized' do
        lambda {
          frequency.distribution(:as => :bogus)
        }.should raise_error
      end

      it 'freezes the hash #distribution' do
        frequency = Frequencies.new(sample)
        lambda {
          frequency.distribution[100] = 0
        }.should raise_error
      end

      it 'freezes the array #distribution' do
        frequency = Frequencies.new(sample)
        lambda {
          frequency.distribution(:as => :array) << [1, 1]
        }.should raise_error
      end
    end

    context '#frequency_mean' do

      it 'calculates the mean of a sample' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze
        frequency = Frequencies.new(sample)
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

        frequency = Frequencies.new(sample){|item| item[:count] }
        mean = frequency.frequency_mean
        mean.should be_within(0.01).of(15.0)
      end
    end

    context '#probability' do

      it 'returns a probability hash' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze

        frequency = Frequencies.new(sample)
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

        frequency = Frequencies.new(sample){|item| item[:count]}
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
        frequency = Frequencies.new(sample)
        lambda {
          frequency.probability[100] = 100
        }.should raise_error
      end
    end

    context '#probability_mean' do

      it 'calculates the mean' do
        sample = [1, 2, 3, 4, 5, 6, 6, 6, 6, 6].freeze
        frequency = Frequencies.new(sample)
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

        frequency = Frequencies.new(sample){|item| item[:count]}
        mean = frequency.probability_mean
        mean.should be_within(0.01).of(4.5)
      end
    end

    context '#probability_variance' do

      it 'calculates the probability variance' do
        sample = [1, 2, 3, 4, 5, 6, 6, 6, 6, 6].freeze
        frequency = Frequencies.new(sample)
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

        frequency = Frequencies.new(sample){|item| item[:count]}
        variance = frequency.probability_variance
        variance.should be_within(0.01).of(3.25)
      end
    end

    context '#frequency_of' do

      let(:sample) { [1, 2, 3, 4, 5, 6, 6, 6, 6, 6].freeze }
      let(:frequency) { Frequencies.new(sample) }

      it 'returns the frequency of the given value' do
        frequency.frequency_of(6).should eq 5
      end

      it 'returns zero when the value is not in the sample' do
        frequency.frequency_of(10).should eq 0
      end
    end

    context '#probability_of' do

      let(:sample) { [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze }
      let(:frequency) { Frequencies.new(sample) }

      it 'returns the frequency of the given value' do
        frequency.probability_of(13).should be_within(0.01).of(0.444)
      end

      it 'returns zero when the value is not in the sample' do
        frequency.probability_of(10).should eq 0
      end
    end

    context 'iterators' do

      let(:sample) { [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze }
      let(:distribution) { {13=>4, 18=>1, 14=>2, 16=>1, 21=>1}.freeze }
      let(:probabilities) { {13=>0.444, 18=>0.111, 14=>0.222, 16=>0.111, 21=>0.111}.freeze }

      subject { Frequencies.new(sample) }

      specify '#each' do

        subject.each do |value, frequency, probability|
          sample.should include(value)
          distribution[value].should eq frequency
          probability.should be_within(0.001).of(probabilities[value])
        end
      end

      specify '#each_value' do

        subject.each_value do |value|
          sample.should include(value)
        end
      end

      specify '#each_frequecy' do

        subject.each_frequency do |frequency|
          distribution.values.should include(frequency)
        end
      end

      specify '#each_probability' do

        subject.each_probability do |probability|
          probabilities.values.should include((probability * 1000).round / 1000.0)
        end
      end
    end

    context '#cumulative_distribution_function' do

      let(:sample) { [1, 2, 2, 3, 5].freeze }
      let(:frequencies) { Frequencies.new(sample) }

      let(:cdf_values) do
        {
          0 => 0,
          1 => 0.2,
          2 => 0.6,
          3 => 0.8,
          4 => 0.8,
          5 => 1
        }
      end

      it 'returns the probability of the given value' do
        (0..5).each do |value|
          probability = frequencies.cdf(value)
          probability.should be_within(0.001).of(cdf_values[value])
        end
      end

      it 'returns zero when the value is smaller than the sample minumin' do
        probability = frequencies.cdf(0)
        probability.should eq 0
      end

      it 'returns one when the value is greater than the sample maximum' do
        probability = frequencies.cdf(6)
        probability.should eq 1
      end
    end

  end
end
