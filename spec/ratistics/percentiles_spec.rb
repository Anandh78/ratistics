require 'spec_helper'

module Ratistics
  describe Percentiles do

    let(:racers) { Racer.from_csv }

    context 'construction' do

      it 'raises an exception if the sample is nil' do
        lambda {
          Percentiles.new(nil)
        }.should raise_error
      end

      it 'creates an empty #ranks if the sample is empty' do
        percentiles = Percentiles.new([])
        percentiles.ranks.should == []
      end

      it 'creates a #ranks for a valid sample array' do
        sample = [5, 1, 9, 3, 14, 9, 7].freeze

        centiles = Percentiles.new(sample).ranks
        centiles.size.should eq 7

        centiles[0][0].should eq 1
        centiles[0][1].should be_within(0.001).of(7.143)

        centiles[1][0].should eq 3
        centiles[1][1].should be_within(0.001).of(21.429)

        centiles[2][0].should eq 5
        centiles[2][1].should be_within(0.001).of(35.714)

        centiles[3][0].should eq 7
        centiles[3][1].should be_within(0.001).of(50.0)

        centiles[4][0].should eq 9
        centiles[4][1].should be_within(0.001).of(64.286)

        centiles[5][0].should eq 9
        centiles[5][1].should be_within(0.001).of(78.571)

        centiles[6][0].should eq 14
        centiles[6][1].should be_within(0.001).of(92.857)
      end

      it 'creates a #ranks when given a block' do
        sample = [
          {:count => 22},
          {:count => 40}
        ].freeze

        centiles = Percentiles.new(sample){|item| item[:count]}
        centiles = centiles.ranks
        centiles.size.should eq 2

        centiles[0][0].should eq 22
        centiles[0][1].should be_within(0.001).of(25.0)

        centiles[1][0].should eq 40
        centiles[1][1].should be_within(0.001).of(75.0)
      end

      it 'does not re-sort a sorted sample' do
        sample = [1, 3, 5, 7, 9, 9, 14]
        sample.should_not_receive(:sort)
        sample.should_not_receive(:sort_by)
        Percentiles.new(sample, :sorted => true)
      end

      it 'does not attempt to sort when a using a block' do
        sample = [
          {:count => 22},
          {:count => 40}
        ]

        sample.should_not_receive(:sort)
        sample.should_not_receive(:sort_by)

        centiles = Percentiles.new(sample){|item| item[:count]}
      end

      it 'freezes the #ranks' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze

        centiles = Percentiles.new(sample)
        lambda {
          centiles.ranks << [100, 100]
        }.should raise_error
      end

      it 'works with an ActiveRecord result set', :ar => true do
        Racer.connect
        sample = Racer.where('age > 0').order('age ASC')

        centiles = Percentiles.new(sample, :sorted => true){|r| r.age}
        centiles = centiles.ranks
        centiles.size.should eq 1597

        centiles[0][0].should eq 10
        centiles[0][1].should be_within(0.001).of(0.031)
      end

      it 'works with Hamster' do
        sample = Hamster.vector(1, 3, 5, 7, 9, 9, 14).freeze
        centiles = Percentiles.new(sample, :sorted => true)
        centiles = centiles.ranks
        centiles.size.should eq 7

        centiles[0][0].should eq 1
        centiles[0][1].should be_within(0.001).of(7.143)
      end
    end

    context '#percent_rank' do

      it 'returns nil for a non-positive index' do
        sample = [40, 15, 35, 20, 40, 50].freeze
        rank = Percentiles.new(sample)
        rank = rank.percent_rank(0)
        rank.should be_nil
      end

      it 'returns nil for an index greater than the collection size' do
        sample = [40, 15, 35, 20, 40, 50].freeze
        rank = Percentiles.new(sample)
        rank = rank.percent_rank(10)
        rank.should be_nil
      end

      it 'returns 50.0% for a one-element sample' do
        Rank.percent_rank([10], 1).should be_within(0.01).of(50.0)
        rank = Percentiles.new([10].freeze)
        rank.percent_rank(1).should be_within(0.01).of(50.0)
      end

      it 'returns the percentile rank for a valid index' do
        sample = [40, 15, 35, 20, 40, 50].freeze
        rank = Percentiles.new(sample)
        rank = rank.percent_rank(3)
        rank.should be_within(0.001).of(41.667)
      end
    end

    context '#percentile' do

      it 'returns the exact percentile of an exact match' do
        sample = [40, 15, 35, 20, 40, 50].freeze
        percentiles = Percentiles.new(sample)
        percentile = percentiles.percentile(20)
        percentile.should eq 25
      end

      it 'returns the calculated percentile for a value not in the sample' do
        sample = [40, 15, 35, 20, 40, 50].freeze
        percentiles = Percentiles.new(sample)
        percentile = percentiles.percentile(25)
        percentile.should be_within(0.001).of(33.333)
      end

      it 'returns the nearest percentile with block' do
        sample = [
          {:count => 15},
          {:count => 20},
          {:count => 35},
          {:count => 40},
          {:count => 40},
          {:count => 50}
        ].freeze

        percentiles = Percentiles.new(sample){|item| item[:count]}
        percentile = percentiles.percentile(20)
        percentile.should eq 25
      end
    end

    context '#nearest_rank' do

      it 'returns the exact rank of an exact match' do
        sample = [15, 20, 35, 40, 50].freeze
        percentiles = Percentiles.new(sample)
        rank = percentiles.nearest_rank(30)
        rank.should eq 20
      end

      it 'returns the nearest rank for a sample' do
        sample = [15, 20, 35, 40, 50].freeze
        percentiles = Percentiles.new(sample)
        rank = percentiles.nearest_rank(35)
        rank.should eq 20
      end

      it 'returns the nearest rank with block' do
        sample = [
          {:count => 15},
          {:count => 20},
          {:count => 35},
          {:count => 40},
          {:count => 50}
        ].freeze
        percentiles = Percentiles.new(sample){|item| item[:count]}
        rank = percentiles.nearest_rank(35)
        rank.should eq 20
      end

      context 'rank calculations' do

        it 'uses the ordinal rank formula when :rank => :ordinal' do
          Math.should_receive(:ordinal_rank).with(40, 5).and_return(2.5)
          sample = [15, 20, 35, 40, 50].freeze
          percentiles = Percentiles.new(sample)
          rank = percentiles.nearest_rank(40, :rank => :ordinal)
          rank.should eq 35
        end

        it 'uses the NIST primary formula when :rank => :nist_primary' do
          Math.should_receive(:nist_primary_rank).with(40, 5).and_return(2.4)
          sample = [15, 20, 35, 40, 50].freeze
          percentiles = Percentiles.new(sample)
          rank = percentiles.nearest_rank(40, :rank => :nist_primary)
          rank.should eq 20
        end

        it 'uses the NIST alternate formula when :rank => :nist_alternate' do
          Math.should_receive(:nist_alternate_rank).with(40, 5).and_return(2.6)
          sample = [15, 20, 35, 40, 50].freeze
          percentiles = Percentiles.new(sample)
          rank = percentiles.nearest_rank(40, :rank => :nist_alternate)
          rank.should eq 35
        end

        it 'uses the ordinal rank formula by default' do
          Math.should_receive(:ordinal_rank).with(40, 5).and_return(2.5)
          sample = [15, 20, 35, 40, 50].freeze
          percentiles = Percentiles.new(sample)
          rank = percentiles.nearest_rank(40)
          rank.should eq 35
        end
      end
    end

    context '#linear_rank' do

      it 'returns the value of the highest rank when the given percentile is higher' do
        sample = [35, 20, 15, 40, 50].freeze
        percentiles = Percentiles.new(sample)
        rank = percentiles.linear_rank(95.0)
        rank.should eq 50
      end

      it 'returns the value of the lowest rank when the given percentile is lower' do
        sample = [35, 20, 15, 40, 50].freeze
        percentiles = Percentiles.new(sample)
        rank = percentiles.linear_rank(0.05)
        rank.should eq 15
      end

      it 'returns the rank when the given value is an exact match' do
        sample = [35, 20, 15, 40, 50].freeze
        percentiles = Percentiles.new(sample)
        rank = percentiles.linear_rank(70.0)
        rank.should eq 40
      end

      it 'uses linear interpolation when the given value is not a match' do
        sample = [35, 20, 15, 40, 50].freeze
        percentiles = Percentiles.new(sample)
        rank = percentiles.linear_rank(40)
        rank.should be_within(0.001).of(27.5)
      end

      it 'returns the linear rank with block' do
        sample = [
          {:count => 15},
          {:count => 20},
          {:count => 35},
          {:count => 40},
          {:count => 50}
        ].freeze

        percentiles = Percentiles.new(sample){|item| item[:count]}
        rank = percentiles.linear_rank(70.0)
        rank.should eq 40
      end
    end

    context 'quartiles' do

      let(:odd_sample) { [73, 75, 80, 84, 90, 92, 93, 94, 96].freeze }
      let(:even_sample) { [1,1,1,1,1,2,2,2,2,2,2,2,2,3,3,3,3,3,4,4,5,6].freeze }

      let(:odd) { Percentiles.new(odd_sample) }
      let(:even) { Percentiles.new(even_sample) }

      specify 'first' do
        even.first_quartile.should be_within(0.001).of(2)
        odd.first_quartile.should be_within(0.001).of(77.5)
      end

      specify 'second' do
        even.second_quartile.should be_within(0.001).of(2)
        odd.second_quartile.should be_within(0.001).of(90.0)
      end

      specify 'third ' do
        even.third_quartile.should be_within(0.001).of(3)
        odd.third_quartile.should be_within(0.001).of(93.5)
      end
    end

    context 'iterators' do

      let(:sample) { [ 1, 3, 5, 7,  9, 14 ].freeze }

      let(:ranks) {
        [[1, 8.333333333333334],
          [3, 25.0],
          [5, 41.666666666666664],
          [7, 58.333333333333336],
          [9, 75.0],
          [14, 91.66666666666667]].freeze
      }

      let(:rank_map) {
        {1 => 8.333333333333334,
         3 => 25.0,
         5 => 41.666666666666664,
         7 => 58.333333333333336,
         9 => 75.0,
         14 => 91.66666666666667}.freeze
      }

      let(:percentile_map) {
        {1 => 8.333333333333332,
         2 => 16.666666666666664,
         3 => 25.0,
         4 => 33.33333333333333,
         5 => 41.66666666666667,
         6 => 50.0,
         7 => 58.333333333333336,
         8 => 66.66666666666666,
         9 => 75.0,
         10 => 83.33333333333334,
         11 => 83.33333333333334,
         12 => 83.33333333333334,
         13 => 83.33333333333334,
         14 => 91.66666666666666}
      }

      subject { Percentiles.new(sample) }

      specify '#each' do

        subject.each do |value, percentile|
          rank_map[value].should be_within(0.001).of(percentile)
        end
      end

      specify '#each_percent_rank' do

        current = 1
        subject.each_percent_rank do |index, percent_rank|
          index.should eq current
          percent_rank.should be_within(0.001).of(ranks[index-1].last)
          current = current + 1
        end
        current.should eq sample.size + 1
      end

      context '#each_with_linear_rank' do

        it 'returns percentiles from 1 to 99 when no range is given' do
          current = 1
          subject.each_with_linear_rank do |percentile, rank|
            percentile.should eq current
            rank.should be_within(0.001).of(subject.linear_rank(percentile))
            current = current + 1
          end
          current.should eq 100
        end

        it 'returns percentiles for a given range' do
          current = 30
          subject.each_with_linear_rank(30..50) do |percentile, rank|
            percentile.should eq current
            rank.should be_within(0.001).of(subject.linear_rank(percentile))
            current = current + 1
          end
          current.should eq 51
        end

        it 'sets the lower bound to 1 when given an invalid lower bound' do
          current = 1
          subject.each_with_linear_rank(-100..9) do |percentile, rank|
            current = current + 1
          end
          current.should eq 10
        end

        it 'sets the upper bound to 99 when given an invalid upper bound' do
          current = 90
          subject.each_with_linear_rank(90..1001) do |percentile, rank|
            current = current + 1
          end
          current.should eq 100
        end
      end

      context '#each_with_nearest_rank' do

        it 'returns percentiles from 1 to 99 when no range is given' do
          current = 1
          subject.each_with_nearest_rank do |percentile, rank|
            sample.should include(rank)
            current = current + 1
          end
          current.should eq 100
        end

        it 'returns percentiles for a given range' do
          current = 30
          subject.each_with_nearest_rank(30..50) do |percentile, rank|
            percentile.should eq current
            sample.should include(rank)
            current = current + 1
          end
          current.should eq 51
        end

        it 'sets the lower bound to 1 when given an invalid lower bound' do
          current = 1
          subject.each_with_nearest_rank(-100..9) do |percentile, rank|
            current = current + 1
          end
          current.should eq 10
        end

        it 'sets the upper bound to 99 when given an invalid upper bound' do
          current = 90
          subject.each_with_nearest_rank(90..1001) do |percentile, rank|
            current = current + 1
          end
          current.should eq 100
        end
      end

      context '#each_rank_and_percentile' do

        it 'iterates over all integers between the sample lower and upper bounds' do
          current = sample.min.floor
          subject.each_rank_and_percentile do |rank, percentile|
            current.should eq rank
            current = current + 1
          end

          max = sample.max
          if max.is_a?(Integer)
            current.should eq max + 1
          else
            current.should eq max.ceil
          end
        end

        it 'returns the approximate percentile for each rank' do
          subject.each_rank_and_percentile do |rank, percentile|
            percentile_map[rank].should be_within(0.001).of(percentile)
          end
        end

        it 'sets the lower bound equal to the first rank rounded down' do
          percentiles = Percentiles.new([5.98, 9.05])
          percentiles.each_rank_and_percentile do |rank, percentile|
            rank.should eq 5
            break
          end
        end

        it 'sets the upper bound equal to the last rank rounded up' do
          percentiles = Percentiles.new([5.98, 9.05])
          current = 5
          percentiles.each_rank_and_percentile do |rank, percentile|
            current = current + 1
          end
          current.should eq 11
        end
      end
    end

  end
end
