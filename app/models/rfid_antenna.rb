class RfidAntenna
	# NOT DENORMALIZED
  include Mongoid::Document
  field :record_status, type: Integer, default: 1
  
  # Set in Maintenance
  belongs_to :rfid_reader  
  field :antenna_number, type: Integer
  field :physical_location, type: String  


  # Set in Scanner Options
  belongs_to :location
  belongs_to :product
  field :handle_code, type: Integer
  belongs_to :asset_type  
end