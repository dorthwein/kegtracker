class Registration
  include Mongoid::Document
	field :record_status, type: Integer, default: 1	
	
	field :brewery_name, type: String
	field :contact_name, type: String
	field :contact_email, type: String
	field :contact_phone, type: String

# Address
	field :street, type: String
	field :city, type: String
	field :state, type: String
	field :zip, type: String


	field :rfid_interest, type: Integer
	field :distributor_count, type: Integer

	field :notes, type: String
	field :asset_count, type: Integer
end
