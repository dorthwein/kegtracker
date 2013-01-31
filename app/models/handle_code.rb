class HandleCode
  include Mongoid::Document
  field :description, type: String    
  field :code, type: Integer    
  field :scanner, type: Boolean
  field :rfid, type: Boolean
end
