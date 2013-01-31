class AssetType
  include Mongoid::Document
  	belongs_to :measurement_unit
	field :description, type: String 
	field :size, type: Float
	
end
