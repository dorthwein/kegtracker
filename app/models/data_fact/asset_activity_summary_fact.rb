class AssetActivitySummaryFact
  include Mongoid::Document
  include Mongoid::Timestamps  	


# Fields
 	field :quantity, type: Integer  
 	field :fact_time, :type => Time	
# Relations

# Networks
	belongs_to :location_network, :class_name => 'Network'	
	field :location_network_description, type: String

	belongs_to :report_entity, :class_name => 'Entity' 		# Who owns the report	

	belongs_to :product_entity, :class_name => 'Entity'	
	field :product_entity_description, type: String # AKA Brewery	


# Product
  	belongs_to :product  
	field :product_description, type: String

# Asset Details
  	belongs_to :asset_type 
	field :asset_type_description, type: String

#	field :asset_status, type: Integer
	field :handle_code, type: Integer  
	field :handle_code_description, type: String	
	
	field :sku_description, type: String  
	field :sku_id, type: String  

	def get_sku_id
		return 'prod_' + self.product_id.to_s + '_type_' + self.asset_type_id.to_s
	end

	def get_sku_description
		return self.product_description.to_s + ' - ' + self.asset_type_description
	end
	
	def build options
		# 


	end


	before_save :sync
	def sync
		self.handle_code_description = HandleCode.get_description(self.handle_code)

		self.sku_description = self.get_sku_description
		self.sku_id = self.get_sku_id

		self.asset_type_description = self.asset_type.description		
		self.product_description = self.product.description	
		self.location_network_description = self.location_network.description			

		self.product_entity = self.product.entity		
		self.product_entity_description = self.product.nil? ? 'Unknown' : self.product_entity.description	

	end
	# Indexes
	index({ report_entity_id: 1 }, { name: "report_entity_index" })	
end
