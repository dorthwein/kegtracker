class MeasurementUnit
  include Mongoid::Document
  	field :record_status, type: Integer, default: 1
  	
  	has_many :asset_types
	field :description, type: String
	field :gallon_equivalent, type: Float
	field :abbreviation, type: String	
end
