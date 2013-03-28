require 'spec_helper'

module Ratistics

  module Load
    describe Dat do

      let(:record_count) { 1633 }

      let(:dat_file) { File.join(File.dirname(__FILE__), '../../data/race.dat') }
      let(:gz_file) { File.join(File.dirname(__FILE__), '../../data/race.dat.gz') }

      let(:dat_definition) do
        [
          {:field => :place, :start => 1, :end => 6, :cast => lambda {|i| i.to_i} },
          {:field => :div_tot, :start =>  7, :end => 15},
          {:field => :div, :start =>  16, :end => 21},
          {:field => :guntime, :start =>  22, :end => 29},
          {:field => :nettime, :start =>  30, :end => 38},
          {:field => :pace, :start =>  39, :end => 44},
          {:field => :name, :start =>  45, :end => 67},
          {:field => :age, :start =>  68, :end => 70, :cast => :to_i},
          {:field => :gender, :start =>  71, :end => 72},
          {:field => :race_num, :start =>  73, :end => 78, :cast => :to_i},
          {:field => :city_state, :start =>  79, :end => 101},
        ]
      end

      let(:dat_row) do
        '    1   1/362  M2039   30:43   30:42   4:57 Brian Harvey           22 M  1422 Allston MA              '
      end

      let(:record_array) do
        [
          '1',
          '1/362',
          'M2039',
          '30:43',
          '30:42',
          '4:57',
          'Brian Harvey',
          '22',
          'M',
          '1422',
          'Allston MA',
        ]
      end

      let(:record_hash) do
        {
          :place => 1,
          :div_tot => '1/362',
          :div => 'M2039',
          :guntime => '30:43',
          :nettime => '30:42',
          :pace => '4:57',
          :name => 'Brian Harvey',
          :age => 22,
          :gender => 'M',
          :race_num => 1422,
          :city_state => 'Allston MA',
        }
      end

      context '#record' do

        it 'loads a record with the definition' do
          record = Ratistics::Load::Dat.record(dat_row, :def => dat_definition)
          record.should eq record_hash
        end

        it 'ignores data fields not in the definition' do
          definition = [{
            :field => :place,
            :start => 1,
            :end => 6,
          }]
          record = Ratistics::Load::Dat.record(dat_row, :def => definition)
          record.should == {:place => '1'}
        end

        it 'supports any data type for the field name' do
          definition = [{
            :field => 'place',
            :start => 1,
            :end => 6,
          }]
          record = Ratistics::Load::Dat.record(dat_row, :def => definition)
          record.should == {'place' => '1'}
        end

        it 'calls a method on every record when the :cast field element is a symbol' do
          definition = [{
            :field => :place,
            :start => 1,
            :end => 6,
            :cast => :to_i
          }]
          record = Ratistics::Load::Dat.record(dat_row, :def => definition)
          record.should == {:place => 1}
        end

        it 'applies the :cast field element to every record when it is a lambda' do
          definition = [{
            :field => :place,
            :start => 1,
            :end => 6,
            :cast => lambda {|i| i.to_i}
          }]
          record = Ratistics::Load::Dat.record(dat_row, :def => definition)
          record.should == {:place => 1}
        end
      end

      context '#data' do

        let(:contents) { File.open(dat_file, 'rb').read }

        it 'loads a single record with the definition' do
          record = Ratistics::Load::Dat.data(dat_row, :def => dat_definition)
          record.count.should eq 1
          record.first.should eq record_hash
        end

        it 'loads multiple records with the definition' do
          record = Ratistics::Load::Dat.data(contents, :def => dat_definition)
          record.count.should eq record_count
          record.first.should eq record_hash
        end

        context 'with Hamster', :hamster => true do

          let(:contents) { dat_row }

          it 'returns a Ruby Array when no :hamster option is given' do
            records = Ratistics::Load::Dat.data(contents, :def => dat_definition)
            records.should be_kind_of Array
          end

          it 'returns a Ruby Array when the :hamster option is set to false' do
            records = Ratistics::Load::Dat.data(contents, :def => dat_definition, :hamster => false)
            records.should be_kind_of Array
          end

          it 'returns a Hamster::Vector when the :hamster option is set to true' do
            records = Ratistics::Load::Dat.data(contents, :def => dat_definition, :hamster => true)
            records.should be_kind_of Hamster::Vector
          end

          it 'returns a Hamster::List when the :hamster option is set to :list' do
            records = Ratistics::Load::Dat.data(contents, :def => dat_definition, :hamster => :list)
            records.should be_kind_of Hamster::List
          end

          it 'returns a Hamster::Stack when the :hamster option is set to :stack' do
            records = Ratistics::Load::Dat.data(contents, :def => dat_definition, :hamster => :stack)
            records.should be_kind_of Hamster::Stack
          end

          it 'returns a Hamster::Queue when the :hamster option is set to :queue' do
            records = Ratistics::Load::Dat.data(contents, :def => dat_definition, :hamster => :queue)
            records.should be_kind_of Hamster::Queue
          end

          it 'returns a Hamster::Set when the :hamster option is set to :set' do
            records = Ratistics::Load::Dat.data(contents, :def => dat_definition, :hamster => :set)
            records.should be_kind_of Hamster::Set
          end

          it 'returns a Hamster::Vector when the :hamster option is set to :vector' do
            records = Ratistics::Load::Dat.data(contents, :def => dat_definition, :hamster => :vector)
            records.should be_kind_of Hamster::Vector
          end

          it 'returns a Hamster::Vector when the :hamster option is set to an unknown type' do
            records = Ratistics::Load::Dat.data(contents, :def => dat_definition, :hamster => :bogus)
            records.should be_kind_of Hamster::Vector
          end
        end
      end

      context '#file' do

        it 'loads records with the definition' do
          records = Ratistics::Load::Dat.file(dat_file, :def => dat_definition)
          records.count.should eq record_count
          records.first.should eq record_hash
        end

        it 'returns a Ruby Array' do
          records = Ratistics::Load::Dat.file(dat_file, :def => dat_definition)
          records.should be_kind_of Array
        end

        it 'supports the :hamster option', :hamster => true do
          records = Ratistics::Load::Dat.file(dat_file, :def => dat_definition, :hamster => true)
          records.should be_kind_of Hamster::Vector
          records.size.should eq record_count
        end
      end

      context '#gz_file' do

        it 'loads records with the definition' do
          records = Ratistics::Load::Dat.gz_file(gz_file, :def => dat_definition)
          records.count.should eq record_count
          records.first.should eq record_hash
        end

        it 'returns a Ruby Array' do
          records = Ratistics::Load::Dat.gz_file(gz_file, :def => dat_definition)
          records.should be_kind_of Array
        end

        it 'supports the :hamster option', :hamster => true do
          records = Ratistics::Load::Dat.gz_file(gz_file, :def => dat_definition, :hamster => true)
          records.should be_kind_of Hamster::Vector
          records.size.should eq record_count
        end
      end

    end
  end
end
