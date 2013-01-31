class RfLog
  include Mongoid::Document
  include Mongoid::Timestamps  
  field :raw_data, type: String    
  field :scan_array, type: String      
  
end
