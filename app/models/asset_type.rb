class AssetType
  include Mongoid::Document
  include Mongoid::Timestamps  

	field :record_status, type: Integer, default: 1  
	
  	belongs_to :measurement_unit
  	field :measurement_unit_description, type: String 
	field :description, type: String 
	field :measurement_unit_qty, type: Float

	field :tier_1, type: Integer	
	field :tier_2, type: Integer	
	field :tier_3, type: Integer	
	field :tier_4, type: Integer	

	field :returnable, type: Integer, :default => 1

	before_save :sync_descriptions		
	def sync_descriptions
		self.measurement_unit_description = self.measurement_unit.description
	end
end
