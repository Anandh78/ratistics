require 'spec_helper'

module Ratistics

  describe Load do

    let(:record_count) { 1633 }

    let(:csv_file) { File.join(File.dirname(__FILE__), '../data/race.csv') }
    let(:psv_file) { File.join(File.dirname(__FILE__), '../data/race.psv') }
    let(:csv_gz_file) { File.join(File.dirname(__FILE__), '../data/race.csv.gz') }
    let(:dat_file) { File.join(File.dirname(__FILE__), '../data/race.dat') }
    let(:dat_gz_file) { File.join(File.dirname(__FILE__), '../data/race.dat.gz') }

    let(:csv_definition) do
      [
        [:place, lambda {|i| i.to_i}],
        :div_tot,
        :div,
        :guntime,
        :nettime,
        :pace,
        [:name],
        [:age, :to_i],
        [:gender],
        [:race_num, :to_i],
        [:city_state]
      ]
    end

    let(:headers) do
      ['place', 'div tot', 'div', 'guntime', 'nettime', 'pace', 'name', 'age', 'gender', 'race num', 'city state']
    end

    let(:csv_headers) do
      'place,"div tot",div,guntime,nettime,pace,name,age,gender,"race num","city state"'
    end

    let(:psv_headers) do
      'place|"div tot"|div|guntime|nettime|pace|name|age|gender|"race num"|"city state"'
    end

    let(:csv_row) do
      '1,1/362,M2039,30:43,30:42,4:57,Brian Harvey,22,M,1422,Allston MA'
    end

    let(:psv_row) do
      '1|1/362|M2039|30:43|30:42|4:57|Brian Harvey|22|M|1422|Allston MA'
    end

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
        1,
        '1/362',
        'M2039',
        '30:43',
        '30:42',
        '4:57',
        'Brian Harvey',
        22,
        'M',
        1422,
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

    let(:record_catalog) do
      [
        [:place, 1],
        [:div_tot, '1/362'],
        [:div, 'M2039'],
        [:guntime, '30:43'],
        [:nettime, '30:42'],
        [:pace, '4:57'],
        [:name, 'Brian Harvey'],
        [:age, 22],
        [:gender, 'M'],
        [:race_num, 1422],
        [:city_state, 'Allston MA'],
      ]
    end

    context 'CSV files' do

      context '#csv_record' do

        context 'without a definition' do

          it 'returns a simple array' do
            record = Ratistics::Load::Csv.record(csv_row)
            record.should eq record_array
          end

          it 'ignores an :as option' do
            record = Ratistics::Load::Csv.record(csv_row, as: :map)
            record.should eq record_array
          end
        end

        context 'with a definition' do

          it 'loads a record with a definition' do
            record = Ratistics::Load::Csv.record(csv_row, def: csv_definition)
            record.should eq record_hash
          end

          it 'ignores fields not in the definition' do
            definition = [:place]
            record = Ratistics::Load::Csv.record(csv_row, def: definition)
            record.should == {:place => '1'}
          end

          it 'ignores fields definied as nil' do
            definition = [
              :place,
              nil,
              :div,
            ]
            record = Ratistics::Load::Csv.record(csv_row, def: definition)
            record.should == {
              :place => '1',
              :div => 'M2039',
            }
          end

          it 'accepts definition fields as arrays' do
            definition = [
              [:place],
            ]
            record = Ratistics::Load::Csv.record(csv_row, def: definition)
            record.should == {:place => '1'}
          end

          it 'calls the method when the second definition field element is a symbol' do
            definition = [
              [:place, :to_i],
            ]
            record = Ratistics::Load::Csv.record(csv_row, def: definition)
            record.should == {:place => 1}
          end

          it 'calls the second definition field element when it is a lambda' do
            definition = [
              [:place, lambda {|i| i.to_i}]
            ]
            record = Ratistics::Load::Csv.record(csv_row, def: definition)
            record.should == {:place => 1}
          end

          it 'supports :col_sep option' do
            record = Ratistics::Load::Csv.record(psv_row, :col_sep => '|')
            record.should eq record_array
          end

          it 'recognizes quoted fields' do
            data = '1,"1/362",M2039,"30:43",30:42,"4:57","Harvey, Brian",22,M,1422,"Allston, MA"'
            result = ["1", "1/362", "M2039", "30:43", "30:42", "4:57", "Harvey, Brian", "22", "M", "1422", "Allston, MA"]
            record = Ratistics::Load::Csv.record(data)
            record.should eq result
          end

          it 'supports empty fields' do
            data = '1,,1/362,M2039,"",30:43,30:42,"4:57","Harvey, Brian",22,,M,1422,Allston MA'
            record = Ratistics::Load::Csv.record(data)
            record.count.should eq 14
            record.should eq ["1", "", "1/362", "M2039", "", "30:43", "30:42", "4:57", "Harvey, Brian", "22", "", "M", "1422", "Allston MA"]
          end

          it 'returns a hash when :as is nil' do
            record = Ratistics::Load::Csv.record(csv_row, def: csv_definition)
            record.should eq record_hash
          end

          it 'returns a hash when :as is :hash' do
            record = Ratistics::Load::Csv.record(csv_row, def: csv_definition, as: :hash)
            record.should eq record_hash
          end

          it 'returns a hash when :as is :map' do
            record = Ratistics::Load::Csv.record(csv_row, def: csv_definition, as: :map)
            record.should eq record_hash
          end

          it 'returns a catalog when :as is :array' do
            record = Ratistics::Load::Csv.record(csv_row, def: csv_definition, as: :array)
            record.should eq record_catalog
          end

          it 'returns a catalog when :as is :catalog' do
            record = Ratistics::Load::Csv.record(csv_row, def: csv_definition, as: :catalog)
            record.should eq record_catalog
          end

          it 'returns a catalog when :as is :catalogue' do
            record = Ratistics::Load::Csv.record(csv_row, def: csv_definition, as: :catalogue)
            record.should eq record_catalog
          end

          it 'returns a simple array when :as is :frame' do
            record = Ratistics::Load::Csv.record(csv_row, def: csv_definition, as: :frame)
            record.should eq record_array
          end

          it 'returns a simple array when :as is :dataframe' do
            record = Ratistics::Load::Csv.record(csv_row, def: csv_definition, as: :dataframe)
            record.should eq record_array
          end
        end
      end

      context '#csv_data' do

        let(:contents) { csv_headers + $/ + csv_row + $/ + csv_row + $/ + csv_row }
        let(:data_rows) { 3 }

        let(:big_content) do
          file = File.open(csv_file, 'rb')
          contents = file.read
          file.close
          return contents
        end

        it 'sets the row keys to the header values when returning a hash' do
          data = Ratistics::Load::Csvdata(contents, headers: true, as: :hash)
          data.length == data_rows
          data.first.keys.should eq headers
        end

        it 'sets the row keys to the header values when returning a catalog' do
          data = Ratistics::Load::Csvdata(contents, headers: true, as: :array)
          data.length == data_rows
          keys = data.first.collect{|item| item.first}
          keys.should eq headers
        end

        it 'sets the first row to the header values when returning a frame' do
          data = Ratistics::Load::Csvdata(contents, headers: true, as: :frame)
          data.length == data_rows + 1
          data.first.should eq headers
        end

        it 'uses headers when present an no definition given' do
          data = Ratistics::Load::Csvdata(contents, headers: true, as: :frame)
          data.length == data_rows + 1
          data.first.should eq headers
        end

        it 'overrides headers with a definition' do
          data = Ratistics::Load::Csvdata(contents, def: csv_definition, headers: true, as: :frame)
          data.length == data_rows + 1
          data.first.should eq record_hash.keys
        end

        it 'names columns numerically when not given headers or a definition' do
          data = Ratistics::Load::Csvdata(big_content, as: :frame)
          data.length == data_rows + 1
          data.first.length.times do |i|
            data.first[i].should =~ /_#{i+1}$/
          end
        end

        it 'applies the definition when given but headers not present' do
          data = Ratistics::Load::Csvdata(contents, def: csv_definition, headers: false, as: :frame)
          data.length == data_rows + 1
          data.first.should eq record_hash.keys
        end

        it 'supports :row_sep option' do
          contents = csv_row + '|' + csv_row + '|' + csv_row 
          data = Ratistics::Load::Csv.data(contents, :row_sep => '|')
          data.length == data_rows
        end

        it 'returns hash elements when :as is nil' do
          data = Ratistics::Load::Csvdata(contents, headers: true, def: csv_definition)
          data.first.should eq record_hash
        end

        it 'supports :as => :hash option' do
          data = Ratistics::Load::Csvdata(contents, headers: true, def: csv_definition, as: :hash)
          data.first.should eq record_hash
        end

        it 'supports :as => :map option' do
          data = Ratistics::Load::Csvdata(contents, headers: true, def: csv_definition, as: :map)
          data.first.should eq record_hash
        end

        it 'supports :as => :array option' do
          data = Ratistics::Load::Csvdata(contents, headers: true, def: csv_definition, as: :array)
          data.first.should eq record_catalog
        end

        it 'supports :as => :catalog option' do
          data = Ratistics::Load::Csvdata(contents, headers: true, def: csv_definition, as: :catalog)
          data.first.should eq record_catalog
        end

        it 'supports :as => :catalogue option' do
          data = Ratistics::Load::Csvdata(contents, headers: true, def: csv_definition, as: :catalogue)
          data.first.should eq record_catalog
        end

        it 'supports :as => :frame option' do
          data = Ratistics::Load::Csvdata(contents, headers: true, def: csv_definition, as: :frame)
          data[0].should eq record_hash.keys
          data[1].should eq record_array
        end

        it 'supports :as => :dataframe option' do
          data = Ratistics::Load::Csvdata(contents, headers: true, def: csv_definition, as: :dataframe)
          data[0].should eq record_hash.keys
          data[1].should eq record_array
        end

        it 'sets the first row equal to the column names when returning a frame' do
          data = Ratistics::Load::Csvdata(contents, headers: true, as: :dataframe)
          data[0].should eq headers
        end

        context 'with Hamster', :hamster => true do

          it 'returns a Ruby Array when no :hamster option is given' do
            records = Ratistics::Load::Csv.data(contents, def: csv_definition)
            records.should be_kind_of Array
          end

          it 'returns a Ruby Array when the :hamster option is set to false' do
            records = Ratistics::Load::Csv.data(contents, def: csv_definition, :hamster => false)
            records.should be_kind_of Array
          end

          it 'returns a Hamster::Vector when the :hamster option is set to true' do
            records = Ratistics::Load::Csv.data(contents, def: csv_definition, :hamster => true)
            records.should be_kind_of Hamster::Vector
          end

          it 'returns a Hamster::List when the :hamster option is set to :list' do
            records = Ratistics::Load::Csv.data(contents, def: csv_definition, :hamster => :list)
            records.should be_kind_of Hamster::List
          end

          it 'returns a Hamster::Stack when the :hamster option is set to :stack' do
            records = Ratistics::Load::Csv.data(contents, def: csv_definition, :hamster => :stack)
            records.should be_kind_of Hamster::Stack
          end

          it 'returns a Hamster::Queue when the :hamster option is set to :queue' do
            records = Ratistics::Load::Csv.data(contents, def: csv_definition, :hamster => :queue)
            records.should be_kind_of Hamster::Queue
          end

          it 'returns a Hamster::Set when the :hamster option is set to :set' do
            records = Ratistics::Load::Csv.data(contents, def: csv_definition, :hamster => :set)
            records.should be_kind_of Hamster::Set
          end

          it 'returns a Hamster::Vector when the :hamster option is set to :vector' do
            records = Ratistics::Load::Csv.data(contents, def: csv_definition, :hamster => :vector)
            records.should be_kind_of Hamster::Vector
          end

          it 'returns a Hamster::Vector when the :hamster option is set to an unknown type' do
            records = Ratistics::Load::Csv.data(contents, def: csv_definition, :hamster => :bogus)
            records.should be_kind_of Hamster::Vector
          end
        end
      end

    end
  end
end
