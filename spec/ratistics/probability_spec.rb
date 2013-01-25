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
          {:count => 13},
        ].freeze

        frequency = Probability.frequency(sample){|item| item[:count]}

        frequency.count.should eq 5
        frequency[13].should eq 4
        frequency[14].should eq 2
        frequency[16].should eq 1
        frequency[18].should eq 1
        frequency[21].should eq 1
      end

      context 'with Hamster' do

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

      it 'calculates the probability from a frequency distribution' do
        sample = {
          13 => 4,
          18 => 1,
          14 => 2,
          16 => 1,
          21 => 1,
        }.freeze

        probability = Probability.probability(sample)

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
          {:count => 13},
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
          {:count => 21} => 1,
        }.freeze

        probability = Probability.probability(sample){|item| item[:count]}

        probability.count.should eq 5
        probability[13].should be_within(0.01).of(0.444)
        probability[14].should be_within(0.01).of(0.222)
        probability[16].should be_within(0.01).of(0.111)
        probability[18].should be_within(0.01).of(0.111)
        probability[21].should be_within(0.01).of(0.111)
      end

      context 'with Hamster' do

        let(:list) { Hamster.list(13, 18, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:vector) { Hamster.vector(13, 18, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:set) { Hamster.set(13, 18, 14, 16, 21).freeze }
        let(:frequency) do
          Hamster.hash({
            13 => 4,
            18 => 1,
            14 => 2,
            16 => 1,
            21 => 1,
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
          probability = Probability.probability(frequency)

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
        sample = { 10 => 0.5 }
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
          21 => 0.1111111111111111,
        }

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
          21 => 22.2222222222222222,
        }

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
          21 => 0.0011111111111111,
        }

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
        Probability.probability_mean([]).should eq 0
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
          47 => 0.030,
        }

        mean = Probability.probability_mean(sample)
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
          {:count => 6},
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
          {:count => 47} => 0.030,
        }.freeze

        mean = Probability.probability_mean(sample){|item| item[:count]}
        mean.should be_within(0.01).of(23.599)
      end

      context 'with Hamster' do

        let(:list) { Hamster.list(1, 2, 3, 4, 5, 6, 6, 6, 6, 6).freeze }
        let(:vector) { Hamster.vector(1, 2, 3, 4, 5, 6, 6, 6, 6, 6).freeze }
        let(:set) { Hamster.set(1, 2, 3, 4, 5, 6).freeze }
        let(:frequency) do
          Hamster.hash({
            7  => 0.123,
            12 => 0.123,
            17 => 0.215,
            22 => 0.061,
            27 => 0.092,
            32 => 0.184,
            37 => 0.123,
            42 => 0.046,
            47 => 0.030,
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
          mean = Probability.probability_mean(frequency)
          mean.should be_within(0.01).of(23.599)
        end
      end
    end

    context '#probability_variance' do

      it 'returns zero for a nil sample' do
        Probability.probability_variance(nil).should eq 0
      end

      it 'returns zero for an empty sample' do
        Probability.probability_variance([]).should eq 0
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

      it 'calculates the variance from a probability distribution' do
        sample = {
          1 => 0.1,
          2 => 0.1,
          3 => 0.1,
          4 => 0.1,
          5 => 0.1,
          6 => 0.5,
        }.freeze

        variance = Probability.probability_variance(sample)
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
          {:count => 6},
        ].freeze

        variance = Probability.probability_variance(sample){|item| item[:count]}
        variance.should be_within(0.01).of(3.25)
      end

      it 'calculates the variance from a probability distribution with a block' do
        sample = {
          {:count => 1} => 0.1,
          {:count => 2} => 0.1,
          {:count => 3} => 0.1,
          {:count => 4} => 0.1,
          {:count => 5} => 0.1,
          {:count => 6} => 0.5,
        }.freeze

        variance = Probability.probability_variance(sample){|item| item[:count]}
        variance.should be_within(0.01).of(3.25)
      end

      context 'with Hamster' do

        let(:list) { Hamster.list(1, 2, 3, 4, 5, 6, 6, 6, 6, 6).freeze }
        let(:vector) { Hamster.vector(1, 2, 3, 4, 5, 6, 6, 6, 6, 6).freeze }
        let(:set) { Hamster.set(1, 2, 3, 4, 5, 6).freeze }
        let(:frequency) do
          Hamster.hash({
            1 => 0.1,
            2 => 0.1,
            3 => 0.1,
            4 => 0.1,
            5 => 0.1,
            6 => 0.5,
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
          mean = Probability.probability_variance(frequency)
          mean.should be_within(0.01).of(3.25)
        end
      end
    end
  end
end
