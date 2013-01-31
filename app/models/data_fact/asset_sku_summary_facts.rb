class AssetSkuSummaryFacts
  include Mongoid::Document
  include Mongoid::Timestamps  	
	
	#out of date?
	belongs_to :report_entity, :class_name => 'Entity' 				# Who owns the report
	
	belongs_to :product	
	belongs_to :location_network, :class_name => 'Network'	
	belongs_to :asset_type  	

#DE-NORMALIZED
	field :sku_description, type: String
	field :location_network_description, type: String
	field :product_description, type: String	
	field :asset_type_description, type: String

	field :empty_quantity, type: Integer				  
	field :full_quantity, type: Integer				  
	field :market_quantity, type: Integer				  
	
	field :fact_time, :type => Time

	before_save :sync_descriptions	
	def sync_descriptions
		# Check Descriptions
		self.asset_type_description = self.asset_type.description			
		self.product_description = self.product.description	
		self.location_network_description = self.location_network.description	
	end	
	# Indexes	
	index({ report_entity_id: 1 }, { name: "report_entity_index" })
end
