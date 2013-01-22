require 'spec_helper'

module Statsrb
  describe Average do

    context 'mean' do

      it 'returns zero for an empty array' do
        data = []
        Average.mean(data).should eq 0
      end

      it 'calculates the average of an array' do
        data = [2, 3, 4, 5, 6]
        Average.mean(data).should be_within(0.1).of(4.0)
      end

      it 'calculates the average using a block when given' do
        data = [
          {:count => 2},
          {:count => 3},
          {:count => 4},
          {:count => 5},
          {:count => 6},
        ]

        mean = Average.mean(data) {|item| item[:count] }
        mean.should be_within(0.1).of(4.0)
      end

    end

  end
end
