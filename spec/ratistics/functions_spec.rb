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

    context '#relative_risk' do

      let(:low) { 16.8 }
      let(:high) { 18.2 }

      let(:low_obj) { {:risk => 16.8} }
      let(:high_obj) { {:risk => 18.2} }

      let(:low_risk) { 0.9230769230769231 }
      let(:high_risk) { 1.0833333333333333 }

      it 'computes a relative risk less than one' do
        risk = Ratistics.relative_risk(low, high)
        risk.should be_within(0.01).of(low_risk)
      end

      it 'computes a relative risk less than one with a block' do
        risk = Ratistics.relative_risk(low_obj, high_obj){|item| item[:risk]}
        risk.should be_within(0.01).of(low_risk)
      end

      it 'computes a relative risk equal to one' do
        risk = Ratistics.relative_risk(low, low)
        risk.should be_within(0.01).of(1.0)
      end

      it 'computes a relative risk equal to one with a block' do
        risk = Ratistics.relative_risk(high_obj, high_obj){|item| item[:risk]}
        risk.should be_within(0.01).of(1.0)
      end

      it 'computes a relative risk greater than one' do
        risk = Ratistics.relative_risk(high, low)
        risk.should be_within(0.01).of(high_risk)
      end

      it 'computes a relative risk greater than one with a block' do
        risk = Ratistics.relative_risk(high_obj, low_obj){|item| item[:risk]}
        risk.should be_within(0.01).of(high_risk)
      end
    end
  end
end
