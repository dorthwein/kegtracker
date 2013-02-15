class AssetLocationNetworkInOutSummaryFact
  include Mongoid::Document
# NORMALIZED 
	belongs_to :report_entity, :class_name => 'Entity' 				# Who owns the report
	
	belongs_to :location_network, :class_name => 'Network'	
	belongs_to :product
	
	belongs_to :asset_type  
#	field :asset_status, type: Integer

#DE-NORMALIZED
	field :location_network_description, type: String
	field :product_description, type: String
	field :product_entity_description, type: String
	
	field :asset_type_description, type: String

	field :in_full_quantity, type: Integer
	field :in_market_quantity, type: Integer
	field :in_empty_quantity, type: Integer
	field :in_total_quantity, type: Integer				  

	field :out_full_quantity, type: Integer				  
	field :out_market_quantity, type: Integer				  
	field :out_empty_quantity, type: Integer				  
	field :out_total_quantity, type: Integer				  

	field :fact_time, :type => Time

	def get_sku_id
		return 'prod_' + self.product_id.to_s + '_type_' + self.asset_type_id.to_s
	end

	def get_sku_description
		return self.product_description.to_s + ' - ' + self.asset_type_description
	end
	def location_network_asset_type_id
		return 'net_' + self.location_network_id.to_s + '_type_' + self.asset_type_id.to_s
	end


	before_save :sync_descriptions	
	def sync_descriptions
		# Check Descriptions
		self.asset_type_description = self.asset_type.description		
		self.product_description = self.product.description	
		self.product_entity_description = self.product.entity.description	
		self.location_network_description = self.location_network.description	

		self.in_total_quantity = self.in_empty_quantity + self.in_market_quantity + self.in_full_quantity
		self.out_total_quantity = self.out_empty_quantity + self.out_market_quantity + self.out_full_quantity

	end	
	# Indexes
	index({ report_entity_id: 1 }, { name: "report_entity_index" })
end
