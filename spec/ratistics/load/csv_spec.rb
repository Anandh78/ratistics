require 'spec_helper'

module Ratistics
  module Load

    describe Csv do

      let(:record_count) { 1633 }

      let(:csv_file) { File.expand_path(File.join(File.dirname(__FILE__), '../../data/race.csv')) }
      let(:psv_file) { File.expand_path(File.join(File.dirname(__FILE__), '../../data/race.psv')) }
      let(:csv_gz_file) { File.expand_path(File.join(File.dirname(__FILE__), '../../data/race.csv.gz')) }
      let(:encoded_file) { File.expand_path(File.join(File.dirname(__FILE__), '../../data/gapminder.csv')) }

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

      let(:contents) { csv_headers + $/ + csv_row + $/ + csv_row + $/ + csv_row }
      let(:data_rows) { 3 }

      let(:big_content) do
        file = File.open(csv_file, 'rb')
        contents = file.read
        file.close
        return contents
      end

      context '#csv_data' do

        it 'ignores fields not in the definition' do
          definition = [:place]
          data = Ratistics::Load::Csv.data(csv_row, def: definition)
          data.first.should == {:place => '1'}
        end

        it 'ignores fields definied as nil when creating a hash' do
          definition = [
            :place,
            nil,
            :div,
          ]
          data = Ratistics::Load::Csv.data(csv_row, def: definition, as: :hash)
          data.first.should == {
            :place => '1',
            :div => 'M2039',
          }
        end

        it 'ignores fields definied as nil when creating a catalog' do
          definition = [
            :place,
            nil,
            :div,
          ]
          data = Ratistics::Load::Csv.data(csv_row, def: definition, as: :catalog)
          data.first.should == [
            [:place, '1'],
            [:div, 'M2039'],
          ]
        end

        it 'accepts definition fields as arrays' do
          definition = [
            [:place],
          ]
          data = Ratistics::Load::Csv.data(csv_row, def: definition)
          data.first.should == {:place => '1'}
        end

        it 'calls the method when the second definition field element is a symbol' do
          definition = [
            [:place, :to_i],
          ]
          data = Ratistics::Load::Csv.data(csv_row, def: definition)
          data.first.should == {:place => 1}
        end

        it 'calls the second definition field element when it is a lambda' do
          definition = [
            [:place, lambda {|i| i.to_i}]
          ]
          data = Ratistics::Load::Csv.data(csv_row, def: definition)
          data.first.should == {:place => 1}
        end

        it 'supports :col_sep option when creating a hash' do
          data = Ratistics::Load::Csv.data(psv_row, :col_sep => '|', def: csv_definition, as: :hash)
          data.first.should eq record_hash
        end

        it 'supports :col_sep option when creating a catalog' do
          data = Ratistics::Load::Csv.data(psv_row, :col_sep => '|', def: csv_definition, as: :catalog)
          data.first.should eq record_catalog
        end

        it 'recognizes quoted fields' do
          data = '1,"1/362",M2039,"30:43",30:42,"4:57","Harvey, Brian",22,M,1422,"Allston, MA"'
          result = ["1", "1/362", "M2039", "30:43", "30:42", "4:57", "Harvey, Brian", "22", "M", "1422", "Allston, MA"]
          data = Ratistics::Load::Csv.data(data, as: :array, headers: false)
          data.first.collect{|i| i.last}.should eq result
        end

        it 'supports empty fields' do
          data = '1,,1/362,M2039,"",30:43,30:42,"4:57","Harvey, Brian",22,,M,1422,Allston MA'
          data = Ratistics::Load::Csv.data(data, as: :array, headers: false)
          data.first.count.should eq 14
          data.first.collect{|i| i.last}.should eq ["1", "", "1/362", "M2039", "", "30:43", "30:42", "4:57", "Harvey, Brian", "22", "", "M", "1422", "Allston MA"]
        end

        it 'force encodes ISO-8859-1 when the option is set' do
          Ratistics::Load::Csv.file(encoded_file, as: :array, headers: false, encoding: :force)
        end

        it 'sets the row keys to the header values when returning a hash' do
          data = Ratistics::Load::Csv.data(contents, headers: true, as: :hash)
          data.length.should eq data_rows
          data.first.keys.should eq headers
        end

        it 'sets the row keys to the header values when returning a catalog' do
          data = Ratistics::Load::Csv.data(contents, headers: true, as: :array)
          data.length.should eq data_rows
          keys = data.first.collect{|item| item.first}
          keys.should eq headers
        end

        it 'uses headers when present an no definition given' do
          data = Ratistics::Load::Csv.data(contents, headers: true, as: :array)
          data.length.should eq data_rows
          data.first.collect{|i| i.first}.should eq headers
        end

        it 'overrides headers with a definition' do
          data = Ratistics::Load::Csv.data(contents, def: csv_definition, headers: true, as: :array)
          data.length.should eq data_rows
          data.first.collect{|i| i.first}.should eq record_hash.keys
        end

        it 'names columns numerically when not given headers or a definition and returning a hash' do
          data = Ratistics::Load::Csv.data(big_content, as: :hash)
          data.length.should eq record_count
          data.first.keys.each_with_index do |key, i|
            key.should =~ /_#{i+1}$/
          end
        end

        it 'names columns numerically when not given headers or a definition and returning a catalog' do
          data = Ratistics::Load::Csv.data(big_content, as: :catalog)
          data.length.should eq record_count
          data.first.collect{|item| item.first}.each_with_index do |key, i|
            key.should =~ /_#{i+1}$/
          end
        end

        it 'applies the definition when given but headers not present' do
          data = Ratistics::Load::Csv.data(contents, def: csv_definition, headers: false, as: :array)
          data.length.should eq data_rows+1
          data.first.collect{|i| i.first}.should eq record_hash.keys
        end

        it 'supports :row_sep option' do
          contents = csv_row + '|' + csv_row + '|' + csv_row 
          data = Ratistics::Load::Csv.data(contents, :row_sep => '|')
          data.length.should eq data_rows
        end

        it 'returns hash elements when :as is nil' do
          data = Ratistics::Load::Csv.data(contents, headers: true, def: csv_definition)
          data.first.should eq record_hash
        end

        it 'supports :as => :hash option' do
          data = Ratistics::Load::Csv.data(contents, headers: true, def: csv_definition, as: :hash)
          data.first.should eq record_hash
        end

        it 'supports :as => :map option' do
          data = Ratistics::Load::Csv.data(contents, headers: true, def: csv_definition, as: :map)
          data.first.should eq record_hash
        end

        it 'supports :as => :array option' do
          data = Ratistics::Load::Csv.data(contents, headers: true, def: csv_definition, as: :array)
          data.first.should eq record_catalog
        end

        it 'supports :as => :catalog option' do
          data = Ratistics::Load::Csv.data(contents, headers: true, def: csv_definition, as: :catalog)
          data.first.should eq record_catalog
        end

        it 'supports :as => :catalogue option' do
          data = Ratistics::Load::Csv.data(contents, headers: true, def: csv_definition, as: :catalogue)
          data.first.should eq record_catalog
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

      context '#csv_file' do

        it 'loads records without a definition' do
          record = Ratistics::Load::Csv.file(csv_file, as: :array, headers: true)
          record.count.should eq record_count-1
        end

        it 'loads records with a definition' do
          record = Ratistics::Load::Csv.file(csv_file, :def => csv_definition)
          record.count.should eq record_count
          record.first.should eq record_hash
        end

        it 'supports :col_sep option' do
          record = Ratistics::Load::Csv.file(psv_file, as: :array, headers: true, :col_sep => '|')
          record.count.should eq record_count-1
        end

        it 'skips the first line when :headers option is true' do
          record = Ratistics::Load::Csv.file(csv_file, :def => csv_definition, :headers => true)
          record.count.should eq record_count-1
          record.first.should_not eq record_hash
        end

        it 'uses the header line for the definition when :headers option is true without a definition' do
          record = Ratistics::Load::Csv.file(csv_file, as: :hash, :headers => true)
          record.count.should eq record_count-1
          record_array.size.should eq record.first.keys.size
        end

        it 'uses the provided definition instead of the header line when :headers option is true' do
          record = Ratistics::Load::Csv.file(csv_file, :def => csv_definition, :headers => true)
          record.count.should eq record_count-1
          record.first.should_not eq record_hash
          record.first.keys.should eq record_hash.keys
        end

        it 'supports the :hamster option', :hamster => true do
          records = Ratistics::Load::Csv.file(csv_file, :def => csv_definition, :hamster => true)
          records.should be_kind_of Hamster::Vector
          records.size.should eq record_count
        end
      end

      context '#csv_gz_file' do

        it 'loads records without a definition' do
          record = Ratistics::Load::Csv.gz_file(csv_gz_file, as: :array, headers: true)
          record.count.should eq record_count-1
        end

        it 'loads records with a definition' do
          record = Ratistics::Load::Csv.gz_file(csv_gz_file, :def => csv_definition)
          record.count.should eq record_count
          record.first.should eq record_hash
        end

        it 'skips the first line when :headers option is true' do
          record = Ratistics::Load::Csv.gz_file(csv_gz_file, :def => csv_definition, :headers => true)
          record.count.should eq record_count-1
          record.first.should_not eq record_hash
        end

        it 'uses the header line for the definition when :headers option is true without a definition' do
          record = Ratistics::Load::Csv.gz_file(csv_gz_file, as: :hash, :headers => true)
          record.count.should eq record_count-1
          record_array.size.should eq record.first.keys.size
        end

        it 'uses the provided definition instead of the header line when :headers option is true' do
          record = Ratistics::Load::Csv.gz_file(csv_gz_file, :def => csv_definition, :headers => true)
          record.count.should eq record_count-1
          record.first.should_not eq record_hash
          record.first.keys.should eq record_hash.keys
        end

        it 'supports the :hamster option', :hamster => true do
          records = Ratistics::Load::Csv.gz_file(csv_gz_file, :def => csv_definition, :hamster => true)
          records.should be_kind_of Hamster::Vector
          records.size.should eq record_count
        end
      end
    end

  end
end
