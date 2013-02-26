require 'spec_helper'
require 'ratistics/monkey'

module Ratistics
  module Monkey

    describe ::Hash do
  
      let(:hash_sample) {
        {
          7  => 8,
          17 => 14,
          27 => 6,
          32 => 12,
          37 => 8,
          22 => 4,
          42 => 3,
          12 => 8,
          47 => 2
        }.freeze
      }
  
      let(:hash_sample_for_block) {
        {
          7  => {:count => 8},
          17 => {:count => 14},
          27 => {:count => 6},
          32 => {:count => 12},
          37 => {:count => 8},
          22 => {:count => 4},
          42 => {:count => 3},
          12 => {:count => 8},
          47 => {:count => 2}
        }.freeze
      }

      context '#to_catalog' do

        it 'creates a catalog from a hash' do
          catalog = hash_sample.to_catalog
          catalog.size.should eq 9
          catalog.should be_a(Array)
          catalog.each do |item|
            item.should be_a(Array)
            item.size.should == 2
          end

          catalog = {:one => 1, :two => 2, :three => 3}.to_catalog
          catalog.size.should eq 3
          catalog.should be_a(Array)
          catalog.each do |item|
            item.should be_a(Array)
            item.size.should == 2
          end
        end

        it 'creates an empty catalog from an empty hash' do
          catalog = {}.to_catalog
          catalog.should be_empty
          catalog.should be_a(Array)
        end

        it 'creates a catalog when given a hash and a block' do
          catalog = hash_sample_for_block.to_catalog{|item| item[:count]}
          catalog.size.should eq 9
          catalog.should be_a(Array)
          catalog.each do |item|
            item.should be_a(Array)
            item.size.should == 2
          end
        end

      end
    end
  end
end
