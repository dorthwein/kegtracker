class AssetSummaryFact
  include Mongoid::Document
  include Mongoid::Timestamps  	

  	# Created in Report Builder
  	# Used by view to generate reports
  
# NORMALIZED
	belongs_to :report_entity, :class_name => 'Entity' 				# Who owns the report
	
	belongs_to :location_network, :class_name => 'Network'	
	belongs_to :product
	belongs_to :product_entity, :class_name => 'Entity'	
	belongs_to :asset_type  	
#DE-NORMALIZED
	field :location_network_description, type: String
	field :product_description, type: String
	field :product_entity_description, type: String # AKA Brewery
	
	field :asset_type_description, type: String

	field :sku_description, type: String
	field :sku_id, type: String

	field :empty_quantity, type: Integer
	field :full_quantity, type: Integer
	field :market_quantity, type: Integer				  	
	field :total_quantity, type: Integer				  	
	field :fact_time, :type => Time

	def get_sku_id
		return 'prod_' + self.product_id.to_s + '_type_' + self.asset_type_id.to_s
	end

	def get_sku_description
		return self.product_description.to_s + ' - ' + self.asset_type_description
	end
	
	before_save :sync_descriptions	
	def sync_descriptions
		# Check Descriptions
		self.asset_type_description = self.asset_type.description			

		self.sku_description = self.get_sku_description
		self.sku_id = self.get_sku_id

		self.product_description = self.product.description	
		self.product_entity = self.product.entity		
		self.product_entity_description = self.product.nil? ? 'Unknown' : self.product_entity.description	

		self.location_network_description = self.location_network.description	

		self.total_quantity = self.empty_quantity + self.full_quantity + self.market_quantity
	end	

	def self.build options

	end

	# Indexes
	index({ report_entity_id: 1 }, { name: "report_entity_index" })
end
