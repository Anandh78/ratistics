require 'spec_helper'

module Ratistics
  describe Rank do

    let(:racers) { Racer.from_csv }

    context '#percentiles' do

      it 'returns an empty array for a nil sample' do
        Rank.percentiles(nil).should eq []
      end

      it 'returns 50.0 for the percentile in a one-element sample' do
        sample = [22].freeze

        centiles = Rank.percentiles(sample)
        centiles.size.should eq 1

        centiles[0][0].should eq 22
        centiles[0][1].should be_within(0.001).of(50.0)
      end

      it 'return 25.0 and 50.0 for the percentiles in a two-element sample' do
        sample = [22, 40].freeze

        centiles = Rank.percentiles(sample)
        centiles.size.should eq 2

        centiles[0][0].should eq 22
        centiles[0][1].should be_within(0.001).of(25.0)

        centiles[1][0].should eq 40
        centiles[1][1].should be_within(0.001).of(75.0)
      end

      it 'returns the percentiles in a multi-element sample' do
        sample = [5, 1, 9, 3, 14, 9, 7].freeze

        centiles = Rank.percentiles(sample)
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

      it 'returns the percentiles with a block' do
        sample = [
          {:count => 22},
          {:count => 40}
        ].freeze

        centiles = Rank.percentiles(sample){|item| item[:count]}
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
        Rank.percentiles(sample, :sorted => true)
      end

      it 'does not attempt to sort when a using a block' do
        sample = [
          {:count => 22},
          {:count => 40}
        ]

        sample.should_not_receive(:sort)
        sample.should_not_receive(:sort_by)

        centiles = Rank.percentiles(sample){|item| item[:count]}
      end

      it 'returns only the higest percentile for duplicate values when :flatten => true' do
        sample = [5, 1, 9, 3, 14, 9, 7].freeze

        centiles = Rank.percentiles(sample, :flatten => true)
        centiles.size.should eq 6

        centiles[0][0].should eq 1
        centiles[0][1].should be_within(0.001).of(7.143)

        centiles[1][0].should eq 3
        centiles[1][1].should be_within(0.001).of(21.429)

        centiles[2][0].should eq 5
        centiles[2][1].should be_within(0.001).of(35.714)

        centiles[3][0].should eq 7
        centiles[3][1].should be_within(0.001).of(50.0)

        centiles[4][0].should eq 9
        centiles[4][1].should be_within(0.001).of(78.571)

        centiles[5][0].should eq 14
        centiles[5][1].should be_within(0.001).of(92.857)
      end

      it 'accepts :flatten => true with a block' do
        sample = [
          {:count => 22},
          {:count => 40},
          {:count => 40}
        ].freeze

        centiles = Rank.percentiles(sample, :flatten => true){|item| item[:count]}
        centiles.size.should eq 2

        centiles[0][0].should eq 22
        centiles[0][1].should be_within(0.001).of(16.667)

        centiles[1][0].should eq 40
        centiles[1][1].should be_within(0.001).of(83.333)
      end

      context 'with ActiveRecord' do

        before(:all) { Racer.connect }

        specify do
          sample = Racer.where('age > 0').order('age ASC')

          centiles = Rank.percentiles(sample){|r| r.age}
          centiles.size.should eq 1597

          centiles[0][0].should eq 10
          centiles[0][1].should be_within(0.001).of(0.031)
        end
      end

      context 'with Hamster' do

        let(:list) { Hamster.list(1, 3, 5, 7, 9, 9, 14).freeze }
        let(:vector) { Hamster.vector(1, 3, 5, 7, 9, 9, 14).freeze }
        let(:set) { Hamster.set(1, 3, 5, 7, 9, 14).freeze }

        specify do
          centiles = Rank.percentiles(list)
          centiles.size.should eq 7

          centiles[0][0].should eq 1
          centiles[0][1].should be_within(0.001).of(7.143)
        end 

        specify do
          centiles = Rank.percentiles(vector, :sorted => true)
          centiles.size.should eq 7

          centiles[0][0].should eq 1
          centiles[0][1].should be_within(0.001).of(7.143)
        end 

        specify do
          centiles = Rank.percentiles(set)
          centiles.size.should eq 6

          centiles[0][0].should eq 1
          centiles[0][1].should be_within(0.001).of(8.333)
        end 
      end
    end

    context '#nearest_rank' do

      it 'returns nil for a nil sample' do
        Rank.nearest_rank(nil, 10).should be_nil
      end

      it 'returns nil for an empty set' do
        Rank.nearest_rank([], 10).should be_nil
      end

      it 'returns the largest value for the 100th percentile' do
        sample = [40, 15, 35, 20, 40, 50].freeze
        rank = Rank.nearest_rank(sample, 100)
        rank.should eq 50
      end

      it 'returns the lowest value for the 0th percentile' do
        sample = [40, 15, 35, 20, 40, 50].freeze
        rank = Rank.nearest_rank(sample, 0)
        rank.should eq 15
      end

      it 'returns the exact rank of an exact match' do
        sample = [15, 20, 35, 40, 50].freeze
        rank = Rank.nearest_rank(sample, 30)
        rank.should eq 20
      end

      it 'returns the nearest rank for a sample less that 100' do
        sample = [40, 15, 35, 20, 40, 50].freeze
        rank = Rank.nearest_rank(sample, 35)
        rank.should eq 35
      end

      it 'returns the nearest rank for a sample larger that 100' do
        sample = racers.collect{|r| r[:age]}.freeze
        rank = Rank.nearest_rank(sample, 35)
        rank.should eq 34
      end

      it 'returns the nearest rank with block' do
        sample = [
          {:count => 15},
          {:count => 20},
          {:count => 35},
          {:count => 40},
          {:count => 50}
        ].freeze
        rank = Rank.nearest_rank(sample, 35){|item| item[:count]}
        rank.should eq 20
      end

      it 'does not re-sort a sorted sample' do
        sample = [15, 20, 35, 40, 50]
        sample.should_not_receive(:sort)
        sample.should_not_receive(:sort_by)
        rank = Rank.nearest_rank(sample, 35, :sorted => true)
      end

      it 'does not attempt to sort when a using a block' do
        sample = [
          {:count => 15},
          {:count => 20},
          {:count => 35},
          {:count => 40},
          {:count => 50}
        ]

        sample.should_not_receive(:sort)
        sample.should_not_receive(:sort_by)
        rank = Rank.nearest_rank(sample, 35){|item| item[:count]}
      end

      context 'for ActiveRecord' do

        before(:all) { Racer.connect }

        specify do
          sample = Racer.all.collect{|r| r.age}
          sample.sort.freeze

          centiles = Rank.percentiles(sample, :sorted => true)
        end
      end

      context 'for Hamster' do

        let(:list) { Hamster.list(40, 15, 35, 20, 40, 50).freeze }
        let(:vector) { Hamster.vector(15, 20, 35, 40, 50).freeze }

        specify { Rank.nearest_rank(list, 35).should eq 35 }

        specify { Rank.nearest_rank(vector, 35, :sorted => true).should eq 20 }
      end
    end

  end
end
