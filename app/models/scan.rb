class Scan
  include Mongoid::Document
  include Mongoid::Timestamps

  field :scans, type: String    
end