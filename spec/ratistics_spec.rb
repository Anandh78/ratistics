require 'spec_helper'

describe Ratistics do

  specify '#aggregates creates a new Aggregates object' do
    Ratistics.aggregates(1, 2, 3).should be_a Ratistics::Aggregates
  end
end
