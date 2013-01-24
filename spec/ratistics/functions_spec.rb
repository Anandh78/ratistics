require 'spec_helper'

module Ratistics

  describe Functions do

    context '#delta' do

      it 'computes the delta of two positive values' do
        Functions.delta(10.5, 5.0).should be_within(0.01).of(5.5)
      end

      it 'computes the delta of two negative values' do
        Functions.delta(-10.5, -5.0).should be_within(0.01).of(5.5)
      end

      it 'computes the delta of a positive and negative value' do
        Functions.delta(10.5, -5.0).should be_within(0.01).of(15.5)
      end

      it 'computes the delta of two positive values with a block' do
        v1 = {:count => 10.5}
        v2 = {:count => 5.0}
        Functions.delta(v1, v2){|x| x[:count]}.should be_within(0.01).of(5.5)
      end

      it 'computes the delta of two negative values with a block' do
        v1 = {:count => -10.5}
        v2 = {:count => -5.0}
        Functions.delta(v1, v2){|x| x[:count]}.should be_within(0.01).of(5.5)
      end

      it 'computes the delta of a positive and negative value with a block' do
        v1 = {:count => 10.5}
        v2 = {:count => -5.0}
        Functions.delta(v1, v2){|x| x[:count]}.should be_within(0.01).of(15.5)
      end

    end
  end
end
