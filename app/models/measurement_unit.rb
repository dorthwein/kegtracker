class MeasurementUnit
  include Mongoid::Document
  	has_many :asset_types
	field :description, type: String
	field :gallon_equivalent, type: Float
	field :abbreviation, type: String	
end
