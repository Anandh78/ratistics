require  'active_record'

module Ratistics

  class Racer < ActiveRecord::Base
  end

  class Pregnancy < ActiveRecord::Base
    belongs_to :female_respondent,
      :primary_key => :caseid,
      :foreign_key => :caseid
  end

  class FemaleRespondent < ActiveRecord::Base
    has_many :pregnancy,
      :primary_key => :caseid,
      :foreign_key => :caseid
  end

end
