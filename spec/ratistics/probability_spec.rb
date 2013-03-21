require 'spec_helper'

module Ratistics
  describe Probability do

    context '#frequency' do

      it 'returns nil for a nil sample' do
        Probability.frequency(nil).should be_nil 
      end

      it 'returns nil for an empty sample' do
        Probability.frequency([].freeze).should be_nil 
      end

      it 'returns a one-element hash for a one-item sample' do
        sample = [10].freeze
        frequency = Probability.frequency(sample)
        frequency.should == {10 => 1}
      end

      it 'returns a multi-element hash for a multi-element sample' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze

        frequency = Probability.frequency(sample)

        frequency.count.should eq 5
        frequency[13].should eq 4
        frequency[14].should eq 2
        frequency[16].should eq 1
        frequency[18].should eq 1
        frequency[21].should eq 1
      end

      it 'returns a one-element hash for a one-item sample with a block' do
        sample = [
          {:count => 10},
        ].freeze

        frequency = Probability.frequency(sample){|item| item[:count]}
        frequency.should == {10 => 1}
      end

      it 'returns a multi-element hash for a multi-element sample with a block' do
        sample = [
          {:count => 13},
          {:count => 18},
          {:count => 13},
          {:count => 14},
          {:count => 13},
          {:count => 16},
          {:count => 14},
          {:count => 21},
          {:count => 13}
        ].freeze

        frequency = Probability.frequency(sample){|item| item[:count]}

        frequency.count.should eq 5
        frequency[13].should eq 4
        frequency[14].should eq 2
        frequency[16].should eq 1
        frequency[18].should eq 1
        frequency[21].should eq 1
      end

      it 'returns a catalog when the :as options is set to :catalog' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze

        frequency = Probability.frequency(sample, :as => :catalog)

        frequency.size.should eq 5
        frequency.should include([13, 4])
        frequency.should include([18, 1])
        frequency.should include([14, 2])
        frequency.should include([16, 1])
        frequency.should include([21, 1])
      end

      it 'returns an array when :as is :array and a block is given' do
        sample = [
          {:count => 13},
          {:count => 18},
          {:count => 13},
          {:count => 14},
          {:count => 13},
          {:count => 16},
          {:count => 14},
          {:count => 21},
          {:count => 13}
        ].freeze

        frequency = Probability.frequency(sample, :as => :array){|item| item[:count]}

        frequency.size.should eq 5
        frequency.should include([13, 4])
        frequency.should include([18, 1])
        frequency.should include([14, 2])
        frequency.should include([16, 1])
        frequency.should include([21, 1])
      end

      context 'with ActiveRecord', :ar => true do

        before(:all) { Racer.connect }

        specify do
          frequency = Probability.frequency(Racer.all.freeze){|r| r.age }

          frequency.count.should eq 67
          frequency[22].should eq 11
          frequency[30].should eq 47
          frequency[26].should eq 39
          frequency[25].should eq 28
          frequency[27].should eq 50
        end

      end

      context 'with Hamster', :hamster => true do

        let(:list) { Hamster.list(13, 18, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:vector) { Hamster.vector(13, 18, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:set) { Hamster.set(13, 18, 14, 16, 21).freeze }

        specify do
          frequency = Probability.frequency(list)

          frequency.count.should eq 5
          frequency[13].should eq 4
          frequency[14].should eq 2
          frequency[16].should eq 1
          frequency[18].should eq 1
          frequency[21].should eq 1
        end

        specify do
          frequency = Probability.frequency(vector)

          frequency.count.should eq 5
          frequency[13].should eq 4
          frequency[14].should eq 2
          frequency[16].should eq 1
          frequency[18].should eq 1
          frequency[21].should eq 1
        end

        specify do
          frequency = Probability.frequency(set)

          frequency.count.should eq 5
          frequency[13].should eq 1
          frequency[14].should eq 1
          frequency[16].should eq 1
          frequency[18].should eq 1
          frequency[21].should eq 1
        end
      end
    end

    context '#frequency_mean' do

      it 'returns zero for a nil sample' do
        Probability.frequency_mean(nil, :from => :frequency).should eq 0
      end

      it 'returns zero for an empty sample' do
        Probability.frequency_mean({}.freeze, :from => :frequency).should eq 0
      end

      it 'calculates the mean of a sample' do
        sample = {
          7  => 8,
          12 => 8,
          17 => 14,
          22 => 4,
          27 => 6,
          32 => 12,
          37 => 8,
          42 => 3,
          47 => 2
        }.freeze

        mean = Probability.frequency_mean(sample, :from => :frequency)
        mean.should be_within(0.01).of(23.6923)
      end

      it 'calculates the mean using a block' do
        sample = {
          {:count => 7 } => 8,
          {:count => 12} => 8,
          {:count => 17} => 14,
          {:count => 22} => 4,
          {:count => 27} => 6,
          {:count => 32} => 12,
          {:count => 37} => 8,
          {:count => 42} => 3,
          {:count => 47} => 2
        }.freeze

        mean = Probability.frequency_mean(sample, :from => :frequency){|item| item[:count] }
        mean.should be_within(0.01).of(23.6923)
      end

      it 'calculates the frequency mean from a raw sample' do
        sample = [1, 1, 1, 2, 2, 3].freeze

        mean = Probability.frequency_mean(sample, :from => :sample)
        mean.should be_within(0.01).of(1.6666666666666665)
      end

      it 'calculates the frequency mean from a frequency distribution' do
        frequency = {
          1 => 3,
          2 => 2,
          3 => 1
        }.freeze

        mean = Probability.frequency_mean(frequency, :from => :frequency)
        mean.should be_within(0.01).of(1.6666666666666665)
      end

      it 'calculates the frequency mean from a probability distribution' do
        probability = {
          1 => 0.5,
          2 => 0.3333333333333333,
          3 => 0.16666666666666666
        }.freeze

        mean = Probability.frequency_mean(probability, :from => :probability)
        mean.should be_within(0.01).of(1.6666666666666665)
      end

      it 'defaults the :from option to sample' do
        sample = [1, 1, 1, 2, 2, 3].freeze

        mean = Probability.frequency_mean(sample)
        mean.should be_within(0.01).of(1.6666666666666665)
      end

      context 'with Hamster', :hamster => true do

        specify do
          sample = Hamster.hash({
            7  => 8,
            12 => 8,
            17 => 14,
            22 => 4,
            27 => 6,
            32 => 12,
            37 => 8,
            42 => 3,
            47 => 2
          }).freeze

          mean = Probability.frequency_mean(sample, :from => :frequency)
          mean.should be_within(0.01).of(23.6923)
        end
      end
    end

    context '#probability' do

      it 'returns nil for a nil sample' do
        Probability.probability(nil).should be_nil 
      end

      it 'returns nil for an empty sample' do
        Probability.probability([].freeze).should be_nil 
      end

      it 'returns a one-element hash for a one-item sample' do
        sample = [10].freeze
        probability = Probability.probability(sample)
        probability.should == {10 => 1}
      end

      it 'returns a multi-element hash for a multi-element sample' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze

        probability = Probability.probability(sample)

        probability.count.should eq 5
        probability[13].should be_within(0.01).of(0.444)
        probability[14].should be_within(0.01).of(0.222)
        probability[16].should be_within(0.01).of(0.111)
        probability[18].should be_within(0.01).of(0.111)
        probability[21].should be_within(0.01).of(0.111)
      end

      it 'calculates the probability from a raw sample' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze

        probability = Probability.probability(sample, :from => :sample)

        probability.count.should eq 5
        probability[13].should be_within(0.01).of(0.444)
      end

      it 'calculates the probability from a frequency distribution' do
        sample = {
          13 => 4,
          18 => 1,
          14 => 2,
          16 => 1,
          21 => 1
        }.freeze

        probability = Probability.probability(sample, :from => :frequency)

        probability.count.should eq 5
        probability[13].should be_within(0.01).of(0.444)
        probability[14].should be_within(0.01).of(0.222)
        probability[16].should be_within(0.01).of(0.111)
        probability[18].should be_within(0.01).of(0.111)
        probability[21].should be_within(0.01).of(0.111)
      end

      it 'returns a one-element hash for a one-item sample with a block' do
        sample = [
          {:count => 10},
        ].freeze

        probability = Probability.probability(sample){|item| item[:count]}
        probability.should == {10 => 1}
      end

      it 'returns a multi-element hash for a multi-element sample with a block' do
        sample = [
          {:count => 13},
          {:count => 18},
          {:count => 13},
          {:count => 14},
          {:count => 13},
          {:count => 16},
          {:count => 14},
          {:count => 21},
          {:count => 13}
        ].freeze

        probability = Probability.probability(sample){|item| item[:count]}

        probability.count.should eq 5
        probability[13].should be_within(0.01).of(0.444)
        probability[14].should be_within(0.01).of(0.222)
        probability[16].should be_within(0.01).of(0.111)
        probability[18].should be_within(0.01).of(0.111)
        probability[21].should be_within(0.01).of(0.111)
      end

      it 'calculates the probability from a frequency distribution with a block' do
        sample = {
          {:count => 13} => 4,
          {:count => 18} => 1,
          {:count => 14} => 2,
          {:count => 16} => 1,
          {:count => 21} => 1
        }.freeze

        probability = Probability.probability(sample, :from => :frequency){|item| item[:count]}

        probability.count.should eq 5
        probability[13].should be_within(0.01).of(0.444)
        probability[14].should be_within(0.01).of(0.222)
        probability[16].should be_within(0.01).of(0.111)
        probability[18].should be_within(0.01).of(0.111)
        probability[21].should be_within(0.01).of(0.111)
      end

      it 'returns a array when the :as options is set to :array' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze

        probability = Probability.probability(sample, :as => :array)

        probability.count.should eq 5

        if RUBY_VERSION >= '1.9'
          probability[0].last.should be_within(0.01).of(0.444)
          probability[1].last.should be_within(0.01).of(0.111)
          probability[2].last.should be_within(0.01).of(0.222)
          probability[3].last.should be_within(0.01).of(0.111)
          probability[4].last.should be_within(0.01).of(0.111)
        end
      end

      it 'returns a catalog when :as is :catalog and a block is given' do
        sample = [
          {:count => 13},
          {:count => 18},
          {:count => 13},
          {:count => 14},
          {:count => 13},
          {:count => 16},
          {:count => 14},
          {:count => 21},
          {:count => 13}
        ].freeze

        probability = Probability.probability(sample, :as => :catalog){|item| item[:count]}

        probability.count.should eq 5

        if RUBY_VERSION >= '1.9'
          probability[0].last.should be_within(0.01).of(0.444)
          probability[1].last.should be_within(0.01).of(0.111)
          probability[2].last.should be_within(0.01).of(0.222)
          probability[3].last.should be_within(0.01).of(0.111)
          probability[4].last.should be_within(0.01).of(0.111)
        end
      end

      it 'returns :incremental probabilities when the option is set'

      context 'with ActiveRecord', :ar => true do

        before(:all) { Racer.connect }

        specify do
          probability = Probability.probability(Racer.all.freeze){|r| r.age }

          probability.count.should eq 67
          probability[22].should be_within(0.001).of(0.00673)
          probability[30].should be_within(0.001).of(0.02878)
          probability[26].should be_within(0.001).of(0.02388)
          probability[25].should be_within(0.001).of(0.01714)
          probability[27].should be_within(0.001).of(0.03061)
        end

      end

      context 'with Hamster', :hamster => true do

        let(:list) { Hamster.list(13, 18, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:vector) { Hamster.vector(13, 18, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:set) { Hamster.set(13, 18, 14, 16, 21).freeze }
        let(:frequency) do
          Hamster.hash({
            13 => 4,
            18 => 1,
            14 => 2,
            16 => 1,
            21 => 1
          }).freeze
        end

        specify do
          probability = Probability.probability(list)

          probability.count.should eq 5
          probability[13].should be_within(0.01).of(0.444)
          probability[14].should be_within(0.01).of(0.222)
          probability[16].should be_within(0.01).of(0.111)
          probability[18].should be_within(0.01).of(0.111)
          probability[21].should be_within(0.01).of(0.111)
        end

        specify do
          probability = Probability.probability(vector)

          probability.count.should eq 5
          probability[13].should be_within(0.01).of(0.444)
          probability[14].should be_within(0.01).of(0.222)
          probability[16].should be_within(0.01).of(0.111)
          probability[18].should be_within(0.01).of(0.111)
          probability[21].should be_within(0.01).of(0.111)
        end

        specify do
          probability = Probability.probability(set)

          probability.count.should eq 5
          probability[13].should be_within(0.01).of(0.2)
          probability[14].should be_within(0.01).of(0.2) 
          probability[16].should be_within(0.01).of(0.2) 
          probability[18].should be_within(0.01).of(0.2) 
          probability[21].should be_within(0.01).of(0.2) 
        end

        specify do
          probability = Probability.probability(frequency, :from => :frequency)

          probability.count.should eq 5
          probability[13].should be_within(0.01).of(0.444)
          probability[14].should be_within(0.01).of(0.222)
          probability[16].should be_within(0.01).of(0.111)
          probability[18].should be_within(0.01).of(0.111)
          probability[21].should be_within(0.01).of(0.111)
        end

      end
    end

    context '#normalize_probability' do

      it 'sets the probability to one for a one-element distribution' do
        sample = { 10 => 0.5 }.freeze
        probability = Probability.normalize_probability(sample)

        probability.count.should eq 1
        probability[10].should eq 1
      end

      it 'does not change the probabilities of a normalized distribution' do
        sample = {
          13 => 0.4444444444444444,
          18 => 0.1111111111111111,
          14 => 0.2222222222222222,
          16 => 0.1111111111111111,
          21 => 0.1111111111111111
        }.freeze

        probability = Probability.normalize_probability(sample)

        probability.count.should eq 5
        probability[13].should be_within(0.01).of(0.444)
        probability[14].should be_within(0.01).of(0.222)
        probability[16].should be_within(0.01).of(0.111)
        probability[18].should be_within(0.01).of(0.111)
        probability[21].should be_within(0.01).of(0.111)
      end

      it 'normalizes a distribution greater than 1.0' do
        sample = {
          13 => 88.8888888888888888,
          18 => 22.2222222222222222,
          14 => 44.4444444444444444,
          16 => 22.2222222222222222,
          21 => 22.2222222222222222
        }.freeze

        probability = Probability.normalize_probability(sample)

        probability.count.should eq 5
        probability[13].should be_within(0.01).of(0.444)
        probability[14].should be_within(0.01).of(0.222)
        probability[16].should be_within(0.01).of(0.111)
        probability[18].should be_within(0.01).of(0.111)
        probability[21].should be_within(0.01).of(0.111)
      end

      it 'normalizes a distribution less than 1.0' do
        sample = {
          13 => 0.0044444444444444,
          18 => 0.0011111111111111,
          14 => 0.0022222222222222,
          16 => 0.0011111111111111,
          21 => 0.0011111111111111
        }.freeze

        probability = Probability.normalize_probability(sample)

        probability.count.should eq 5
        probability[13].should be_within(0.01).of(0.444)
        probability[14].should be_within(0.01).of(0.222)
        probability[16].should be_within(0.01).of(0.111)
        probability[18].should be_within(0.01).of(0.111)
        probability[21].should be_within(0.01).of(0.111)
      end

    end

    context '#probability_mean' do

      it 'returns zero for a nil sample' do
        Probability.probability_mean(nil).should eq 0
      end

      it 'returns zero for an empty sample' do
        Probability.probability_mean([].freeze).should eq 0
      end

      it 'calculates the mean for a one-element sample' do
        sample = [1].freeze
        mean = Probability.probability_mean(sample)
        mean.should be_within(0.01).of(1.0)
      end

      it 'calculates the mean for a multi-element sample' do
        sample = [1, 2, 3, 4, 5, 6, 6, 6, 6, 6].freeze
        mean = Probability.probability_mean(sample)
        mean.should be_within(0.01).of(4.5)
      end

      it 'calculates the mean from a probability distribution' do
        sample = {
          7  => 0.123,
          12 => 0.123,
          17 => 0.215,
          22 => 0.061,
          27 => 0.092,
          32 => 0.184,
          37 => 0.123,
          42 => 0.046,
          47 => 0.030
        }.freeze

        mean = Probability.probability_mean(sample, :from => :probability)
        mean.should be_within(0.01).of(23.599)
      end

      it 'calculates the mean for a sample with a block' do
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
          {:count => 6}
        ].freeze

        mean = Probability.probability_mean(sample){|item| item[:count]}
        mean.should be_within(0.01).of(4.5)
      end

      it 'calculates the mean from a probability distribution with a block' do
        sample = {
          {:count => 7 } => 0.123,
          {:count => 12} => 0.123,
          {:count => 17} => 0.215,
          {:count => 22} => 0.061,
          {:count => 27} => 0.092,
          {:count => 32} => 0.184,
          {:count => 37} => 0.123,
          {:count => 42} => 0.046,
          {:count => 47} => 0.030
        }.freeze

        mean = Probability.probability_mean(sample, :from => :probability){|item| item[:count]}
        mean.should be_within(0.01).of(23.599)
      end

      context 'with Hamster', :hamster => true do

        let(:list) { Hamster.list(1, 2, 3, 4, 5, 6, 6, 6, 6, 6).freeze }
        let(:vector) { Hamster.vector(1, 2, 3, 4, 5, 6, 6, 6, 6, 6).freeze }
        let(:set) { Hamster.set(1, 2, 3, 4, 5, 6).freeze }
        let(:probability) do
          Hamster.hash({
            7  => 0.123,
            12 => 0.123,
            17 => 0.215,
            22 => 0.061,
            27 => 0.092,
            32 => 0.184,
            37 => 0.123,
            42 => 0.046,
            47 => 0.030
          }).freeze
        end

        specify do
          mean = Probability.probability_mean(list)
          mean.should be_within(0.01).of(4.5)
        end

        specify do
          mean = Probability.probability_mean(vector)
          mean.should be_within(0.01).of(4.5)
        end

        specify do
          mean = Probability.probability_mean(set)
          mean.should be_within(0.01).of(3.5)
        end

        specify do
          mean = Probability.probability_mean(probability, :from => :probability)
          mean.should be_within(0.01).of(23.599)
        end
      end
    end

    context '#probability_variance' do

      it 'returns zero for a nil sample' do
        Probability.probability_variance(nil).should eq 0
      end

      it 'returns zero for an empty sample' do
        Probability.probability_variance([].freeze).should eq 0
      end

      it 'calculates the variance for a one-element sample' do
        sample = [1].freeze
        variance = Probability.probability_variance(sample)
        variance.should be_within(0.01).of(0.0)
      end

      it 'calculates the variance for a multi-element sample' do
        sample = [1, 2, 3, 4, 5, 6, 6, 6, 6, 6].freeze
        variance = Probability.probability_variance(sample)
        variance.should be_within(0.01).of(3.25)
      end

      it 'recognizes the :from => :sample option' do
        sample = [1, 2, 3, 4, 5, 6, 6, 6, 6, 6].freeze
        variance = Probability.probability_variance(sample, :from => :sample)
        variance.should be_within(0.01).of(3.25)
      end

      it 'calculates the variance from a frequency distribution' do
        frequency = {
          1 => 1,
          2 => 1,
          3 => 1,
          4 => 1,
          5 => 1,
          6 => 5
        }.freeze

        variance = Probability.probability_variance(frequency, :from => :frequency)
        variance.should be_within(0.01).of(3.25)
      end

      it 'calculates the variance from a probability distribution' do
        probability = {
          1 => 0.1,
          2 => 0.1,
          3 => 0.1,
          4 => 0.1,
          5 => 0.1,
          6 => 0.5
        }.freeze

        variance = Probability.probability_variance(probability, :from => :probability)
        variance.should be_within(0.01).of(3.25)
      end

      it 'calculates the variance for a sample with a block' do
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
          {:count => 6}
        ].freeze

        variance = Probability.probability_variance(sample){|item| item[:count]}
        variance.should be_within(0.01).of(3.25)
      end

      it 'calculates the variance from a frequency distribution with a block' do
        sample = {
          {:count => 1} => 1,
          {:count => 2} => 1,
          {:count => 3} => 1,
          {:count => 4} => 1,
          {:count => 5} => 1,
          {:count => 6} => 5
        }.freeze

        variance = Probability.probability_variance(sample, :from => :frequency){|item| item[:count]}
        variance.should be_within(0.01).of(3.25)
      end

      it 'calculates the variance from a probability distribution with a block' do
        sample = {
          {:count => 1} => 0.1,
          {:count => 2} => 0.1,
          {:count => 3} => 0.1,
          {:count => 4} => 0.1,
          {:count => 5} => 0.1,
          {:count => 6} => 0.5
        }.freeze

        variance = Probability.probability_variance(sample, :from => :probability){|item| item[:count]}
        variance.should be_within(0.01).of(3.25)
      end

      context 'with Hamster', :hamster => true do

        let(:list) { Hamster.list(1, 2, 3, 4, 5, 6, 6, 6, 6, 6).freeze }
        let(:vector) { Hamster.vector(1, 2, 3, 4, 5, 6, 6, 6, 6, 6).freeze }
        let(:set) { Hamster.set(1, 2, 3, 4, 5, 6).freeze }
        let(:probability) do
          Hamster.hash({
            1 => 0.1,
            2 => 0.1,
            3 => 0.1,
            4 => 0.1,
            5 => 0.1,
            6 => 0.5
          }).freeze
        end

        specify do
          mean = Probability.probability_variance(list)
          mean.should be_within(0.01).of(3.25)
        end

        specify do
          mean = Probability.probability_variance(vector)
          mean.should be_within(0.01).of(3.25)
        end

        specify do
          mean = Probability.probability_variance(set)
          mean.should be_within(0.01).of(2.91)
        end

        specify do
          mean = Probability.probability_variance(probability, :from => :probability)
          mean.should be_within(0.01).of(3.25)
        end
      end
    end

    context '#cumulative_distribution_function' do

      let(:sorted_sample) { [1, 2, 2, 3, 5].freeze }
      let(:unsorted_sample) { [5, 2, 1, 3, 2].freeze }
      let(:flat_sample) { [1, 2, 2, 2, 2, 2, 2, 2, 2, 3] }

      let(:sample_for_block) do
        [
          {:count => 1},
          {:count => 2},
          {:count => 2},
          {:count => 3},
          {:count => 5}
        ]
      end

      let(:frequency) do
        {
          1 => 1,
          2 => 2,
          3 => 1,
          5 => 1
        }
      end

      let(:frequency_with_block) do
        {
          {:count => 1} => 1,
          {:count => 2} => 2,
          {:count => 3} => 1,
          {:count => 5} => 1
        }
      end

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

      it 'returns zero for a nil sample' do
        Probability.cdf(nil, 2).should eq 0
      end

      it 'returns zero for an empty sample' do
        Probability.cdf([].freeze, 2).should eq 0
      end

      it 'returns the probability of the given value' do
        (0..5).each do |value|
          probability = Probability.cdf(sorted_sample, value)
          probability.should be_within(0.001).of(cdf_values[value])
        end
      end

      it 'returns zero when the value is smaller than the sample minumin' do
        probability = Probability.cdf(sorted_sample, 0)
        probability.should eq 0
      end

      it 'returns one when the value is greater than the sample maximum' do
        probability = Probability.cdf(sorted_sample, 6)
        probability.should eq 1
      end

      it 'returns the probability when given a block' do
        (0..5).each do |value|
          probability = Probability.cdf(sample_for_block, value){|item| item[:count]}
          probability.should be_within(0.001).of(cdf_values[value])
        end
      end

      it 'returns the probability on an unsorted sample' do
        (0..5).each do |value|
          probability = Probability.cdf(unsorted_sample, value)
          probability.should be_within(0.001).of(cdf_values[value])
        end
      end

      it 'returns the probability on a relatively flat sample' do
        probability = Probability.cdf(flat_sample,2)
        probability.should be_within(0.001).of(0.9)
      end

      it 'recognizes the option :from => :sample' do
        (0..5).each do |value|
          probability = Probability.cdf(sorted_sample, value, :from => :sample)
          probability.should be_within(0.001).of(cdf_values[value])
        end
      end

      it 'returns the probability when given a frequency' do
        (0..5).each do |value|
          probability = Probability.cdf(frequency, value, :from => :frequency)
          probability.should be_within(0.001).of(cdf_values[value])
        end
      end

      it 'returns the probability when given a frequency with a block' do
        (0..5).each do |value|
          probability = Probability.cdf(frequency_with_block, value, :from => :frequency){|item| item[:count]}
          probability.should be_within(0.001).of(cdf_values[value])
        end
      end

      it 'does not attempt to sort when a using a block' do
        sample = [
          {:count => 2},
        ]

        sample.should_not_receive(:sort)
        sample.should_not_receive(:sort_by)

        Probability.cdf(sample, 2, :sorted => false) {|item| item[:count] }
      end

      it 'does not re-sort a sorted sample' do
        sample = sorted_sample.dup
        sample.should_not_receive(:sort)
        sample.should_not_receive(:sort_by)
        Probability.cdf(sample, 2, :sorted => true)
      end

      context 'with ActiveRecord', :ar => true do

        before(:all) { Racer.connect }

        specify do
          sample = Racer.where('age > 0').order('age ASC')

          probability = Probability.cdf(sample, 38){|r| r.age}
          probability.should be_within(0.00).of(0.5003130870381967)
        end
      end

      context 'with Hamster', :hamster => true do

        let(:list) { Hamster.list(1, 2, 2, 3, 5).freeze }
        let(:vector) { Hamster.vector(1, 2, 2, 3, 5).freeze }

        specify do
          probability = Probability.cdf(list, 2, :sorted => true)
          probability.should be_within(0.001).of(0.6)
        end

        specify do
          probability = Probability.cdf(vector, 2, :sorted => true)
          probability.should be_within(0.001).of(0.6)
        end
      end
    end

    context '#cumulative_distribution_function_value' do

      let(:sorted_sample) { [1, 2, 2, 3, 5].freeze }
      let(:unsorted_sample) { [2, 1, 3, 2, 5].freeze }
      let(:flat_sample) { [1, 2, 2, 2, 2, 2, 2, 2, 2, 3] }

      let(:sorted_sample_with_block) do
        [
          {:count => 1},
          {:count => 2},
          {:count => 2},
          {:count => 3},
          {:count => 5}
        ].freeze
      end

      it 'returns nil for a nil sample' do
        Probability.cdf_value(nil, 0.5).should be_nil
      end

      it 'returns nil for an empty sample' do
        Probability.cdf_value([], 0.5).should be_nil
      end

      it 'returns the value for the given probability' do
        Probability.cdf_value(sorted_sample, 0.0, :sorted => true).should eq 1
        Probability.cdf_value(sorted_sample, 0.1, :sorted => true).should eq 1
        Probability.cdf_value(sorted_sample, 0.2, :sorted => true).should eq 1
        Probability.cdf_value(sorted_sample, 0.3, :sorted => true).should eq 2
        Probability.cdf_value(sorted_sample, 0.4, :sorted => true).should eq 2
        Probability.cdf_value(sorted_sample, 0.5, :sorted => true).should eq 2
        Probability.cdf_value(sorted_sample, 0.6).should eq 2
        Probability.cdf_value(sorted_sample, 0.7).should eq 3
        Probability.cdf_value(sorted_sample, 0.8).should eq 3
        Probability.cdf_value(sorted_sample, 0.9).should eq 5
        Probability.cdf_value(sorted_sample, 1.0).should eq 5
      end

      it 'returns nil when the probability is less than zero' do
        Probability.cdf_value(sorted_sample, -0.1, :sorted => true).should be_nil
      end

      it 'returns the sample minimum when the probability is zero' do
        Probability.cdf_value(sorted_sample, 0, :sorted => true).should eq 1
      end

      it 'returns the sample maximum when the probability is one' do
        Probability.cdf_value(sorted_sample, 1, :sorted => true).should eq 5
      end

      it 'returns nil when the probability is greater than one' do
        Probability.cdf_value(sorted_sample, 1.1, :sorted => true).should be_nil
      end

      it 'returns the value when given a block' do
        Probability.cdf_value(sorted_sample_with_block, 0.0){|x| x[:count] }.should eq 1
        Probability.cdf_value(sorted_sample_with_block, 0.1){|x| x[:count] }.should eq 1
        Probability.cdf_value(sorted_sample_with_block, 0.2){|x| x[:count] }.should eq 1
        Probability.cdf_value(sorted_sample_with_block, 0.3){|x| x[:count] }.should eq 2
        Probability.cdf_value(sorted_sample_with_block, 0.4){|x| x[:count] }.should eq 2
        Probability.cdf_value(sorted_sample_with_block, 0.5){|x| x[:count] }.should eq 2
        Probability.cdf_value(sorted_sample_with_block, 0.6){|x| x[:count] }.should eq 2
        Probability.cdf_value(sorted_sample_with_block, 0.7){|x| x[:count] }.should eq 3
        Probability.cdf_value(sorted_sample_with_block, 0.8){|x| x[:count] }.should eq 3
        Probability.cdf_value(sorted_sample_with_block, 0.9){|x| x[:count] }.should eq 5
        Probability.cdf_value(sorted_sample_with_block, 1.0){|x| x[:count] }.should eq 5
      end

      it 'returns the value on an unsorted sample' do
        Probability.cdf_value(unsorted_sample, 0.0).should eq 1
        Probability.cdf_value(unsorted_sample, 0.1).should eq 1
        Probability.cdf_value(unsorted_sample, 0.2).should eq 1
        Probability.cdf_value(unsorted_sample, 0.3).should eq 2
        Probability.cdf_value(unsorted_sample, 0.4).should eq 2
        Probability.cdf_value(unsorted_sample, 0.5, :sorted => false).should eq 2
        Probability.cdf_value(unsorted_sample, 0.6, :sorted => false).should eq 2
        Probability.cdf_value(unsorted_sample, 0.7, :sorted => false).should eq 3
        Probability.cdf_value(unsorted_sample, 0.8, :sorted => false).should eq 3
        Probability.cdf_value(unsorted_sample, 0.9, :sorted => false).should eq 5
        Probability.cdf_value(unsorted_sample, 1.0, :sorted => false).should eq 5
      end

      it 'returns the value on a relatively flat sample' do
        Probability.cdf_value(flat_sample, 0.0).should eq 1
        Probability.cdf_value(flat_sample, 0.1).should eq 1
        Probability.cdf_value(flat_sample, 0.2).should eq 2
        Probability.cdf_value(flat_sample, 0.3).should eq 2
        Probability.cdf_value(flat_sample, 0.4).should eq 2
        Probability.cdf_value(flat_sample, 0.5).should eq 2
        Probability.cdf_value(flat_sample, 0.6).should eq 2
        Probability.cdf_value(flat_sample, 0.7).should eq 2
        Probability.cdf_value(flat_sample, 0.8).should eq 2
        Probability.cdf_value(flat_sample, 0.9).should eq 2
        Probability.cdf_value(flat_sample, 1.0).should eq 3
      end

      it 'recognizes the option :from => :sample' do
        Probability.cdf_value(sorted_sample, 0.0, :from => :sample).should eq 1
        Probability.cdf_value(sorted_sample, 0.1, :from => :sample).should eq 1
        Probability.cdf_value(sorted_sample, 0.9, :from => :sample).should eq 5
        Probability.cdf_value(sorted_sample, 1.0, :from => :sample).should eq 5
      end

      it 'returns the value when given a frequency' do
        freq = {1 => 1, 2 => 2, 3 => 1, 5 => 1}
        Probability.cdf_value(freq, 0.0, :from => :freq).should eq 1
        Probability.cdf_value(freq, 0.1, :from => :freq).should eq 1
        Probability.cdf_value(freq, 0.2, :from => :freq).should eq 1
        Probability.cdf_value(freq, 0.3, :from => :freq).should eq 2
        Probability.cdf_value(freq, 0.4, :from => :freq).should eq 2
        Probability.cdf_value(freq, 0.5, :from => :freq).should eq 2
        Probability.cdf_value(freq, 0.6, :from => :freq).should eq 2
        Probability.cdf_value(freq, 0.7, :from => :freq).should eq 3
        Probability.cdf_value(freq, 0.8, :from => :freq).should eq 3
        Probability.cdf_value(freq, 0.9, :from => :freq).should eq 5
        Probability.cdf_value(freq, 1.0, :from => :freq).should eq 5
      end

      it 'returns the value when given a frequency with a block' do
        freq = {
          {:count => 1} => 1,
          {:count => 2} => 2,
          {:count => 3} => 1,
          {:count => 5} => 1
        }
        Probability.cdf_value(freq, 0.0, :from => :freq){|x| x[:count] }.should eq 1
        Probability.cdf_value(freq, 0.1, :from => :freq){|x| x[:count] }.should eq 1
        Probability.cdf_value(freq, 0.2, :from => :freq){|x| x[:count] }.should eq 1
        Probability.cdf_value(freq, 0.3, :from => :freq){|x| x[:count] }.should eq 2
        Probability.cdf_value(freq, 0.4, :from => :freq){|x| x[:count] }.should eq 2
        Probability.cdf_value(freq, 0.5, :from => :freq){|x| x[:count] }.should eq 2
        Probability.cdf_value(freq, 0.6, :from => :freq){|x| x[:count] }.should eq 2
        Probability.cdf_value(freq, 0.7, :from => :freq){|x| x[:count] }.should eq 3
        Probability.cdf_value(freq, 0.8, :from => :freq){|x| x[:count] }.should eq 3
        Probability.cdf_value(freq, 0.9, :from => :freq){|x| x[:count] }.should eq 5
        Probability.cdf_value(freq, 1.0, :from => :freq){|x| x[:count] }.should eq 5
      end

      it 'does not attempt to sort when a using a block' do
        sample = [
          {:count => 2},
        ]

        sample.should_not_receive(:sort)
        sample.should_not_receive(:sort_by)

        Probability.cdf_value(sample, 0.2, :sorted => false) {|item| item[:count] }
      end

      it 'does not re-sort a sorted sample' do
        sample = sorted_sample.dup
        sample.should_not_receive(:sort)
        sample.should_not_receive(:sort_by)
        Probability.cdf_value(sample, 0.2, :sorted => true)
      end

      context 'with ActiveRecord', :ar => true do

        before(:all) { Racer.connect }

        specify do
          sample = Racer.where('age > 0').order('age ASC')

          value = Probability.cdf_value(sample, 0.5){|r| r.age}
          value.should eq 38
        end
      end

      context 'with Hamster', :hamster => true do

        let(:list) { Hamster.list(1, 2, 2, 3, 5).freeze }
        let(:vector) { Hamster.vector(1, 2, 2, 3, 5).freeze }

        specify do
          value = Probability.cdf_value(list, 0.6, :sorted => true)
          value.should eq 2
        end

        specify do
          value = Probability.cdf_value(vector, 0.6, :sorted => true)
          value.should eq 2
        end
      end
    end

  end
end
