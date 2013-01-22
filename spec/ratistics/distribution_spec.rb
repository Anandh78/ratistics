require 'spec_helper'

module Ratistics
  describe Distribution do

    context '#range' do

      it 'returns zero for an empty list' do
        data = []
        Distribution.range(data).should eq 0
      end

      it 'returns zero for a one-element list' do
        data = [1]
        Distribution.range(data).should eq 0
      end

      it 'returns the range for a sorted list' do
        data = [13, 13, 13, 13, 14, 14, 16, 18, 21]
        range = Distribution.range(data, true)
        range.should be_within(0.01).of(8.0)
      end

      it 'returns the range for an unsorted list' do
        data = [13, 18, 13, 14, 13, 16, 14, 21, 13]
        range = Distribution.range(data, false)
        range.should be_within(0.01).of(8.0)
      end

      it 'does not re-sort a sorted list' do
        data = [13, 13, 13, 13, 14, 14, 16, 18, 21]
        data.should_not_receive(:sort)
        data.should_not_receive(:sort_by)
        Distribution.range(data, true)
      end

      it 'calculates the range when using a block' do
        data = [
          {:count => 13},
          {:count => 13},
          {:count => 13},
          {:count => 13},
          {:count => 14},
          {:count => 14},
          {:count => 16},
          {:count => 18},
          {:count => 21},
        ]

        range = Distribution.range(data) {|item| item[:count] }
        range.should be_within(0.01).of(8.0)
      end

      it 'does not attempt to sort when a using a block' do
        data = [
          {:count => 2},
        ]

        data.should_not_receive(:sort)
        data.should_not_receive(:sort_by)

        Distribution.range(data, false) {|item| item[:count] }
      end
    end
  end
end
