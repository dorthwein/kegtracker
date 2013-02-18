class AssetFillToFillCycleFactByFillNetwork
 	include Mongoid::Document
 	include Mongoid::Timestamps  	

	belongs_to :report_entity, :class_name => 'Entity' 				# Who owns the report	
	belongs_to :fill_network, :class_name => 'Network'	
	belongs_to :product
	belongs_to :asset_type  
	field :fact_time, :type => Time

	field :fill_network_description, type: String
	field :product_description, type: String
	
	belongs_to :product_entity, :class_name => 'Entity'
	field :product_entity_description, type: String # AKA Brewery
	
	field :asset_type_description, type: String

	field :sku_description, type: String
	field :sku_id, type: String


	field :max_time, :type => Integer
	field :avg_time, :type => Integer
	field :min_time, :type => Integer


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

		self.fill_network_description = self.fill_network.description	
	end	
end
