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

  end
end
