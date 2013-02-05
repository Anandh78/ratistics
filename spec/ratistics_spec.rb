require 'spec_helper'

describe Ratistics do

  specify '#aggregates_for creates a new Aggregates object' do
    Ratistics.aggregates_for(1, 2, 3).should be_a Ratistics::Aggregates
  end
end
