class AssetActivitySummaryFact
  include Mongoid::Document
  include Mongoid::Timestamps  	


# Fields
 	field :quantity, type: Integer  
 	field :fact_time, :type => Time	
# Relations

# Networks
	belongs_to :location_network, :class_name => 'Network'	

# Entity
	belongs_to :report_entity, :class_name => 'Entity' 		# Who owns the report

# Product
  	belongs_to :product  

# Asset Details
  	belongs_to :asset_type 
	field :asset_status, type: Integer

	field :handle_code, type: Integer  

# Location

# Activity

# Reporting

# DE-NORMALIZED
	field :location_network_description, type: String
	
	field :asset_type_description, type: String
	field :product_description, type: String

	field :handle_code_description, type: String

	
	before_save :sync
	def sync
		self.asset_type_description = self.asset_type.description		

		self.product_description = self.product.description	
		self.location_network_description = self.location_network.description			
	end

	# Indexes
	index({ report_entity_id: 1 }, { name: "report_entity_index" })	
end
