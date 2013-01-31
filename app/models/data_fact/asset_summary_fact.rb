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
	
	field :asset_status, type: Integer

#DE-NORMALIZED
	field :location_network_description, type: String
	field :product_description, type: String
	field :product_entity_description, type: String # AKA Brewery
	
	field :asset_type_description, type: String

	field :empty_quantity, type: Integer
	field :full_quantity, type: Integer
	field :market_quantity, type: Integer				  	
	field :fact_time, :type => Time
	  
	def asset_status_description
		case self.asset_status.to_i
		when 0
		  return 'Empty'  
		when 1
		  return 'Full' 
		when 2
		  return 'Market' 
		when 3
		  return 'Damaged'  
		when 4
		  return 'Lost' 
		else
		  return 'Unknown' 
		end
	end

	def sku_id
		return 'prod_' + self.product_id.to_s + '_type_' + self.asset_type_id.to_s
	end

	def sku_description
		return self.product_description.to_s + ' - ' + self.asset_type_description
	end

	before_save :sync_descriptions	
	def sync_descriptions
		# Check Descriptions
		self.asset_type_description = self.asset_type.description			
		
		self.product_description = self.product.description	
		self.product_entity = self.product.entity		
		self.product_entity_description = self.product.nil? ? 'Unknown' : self.product_entity.description	

		self.location_network_description = self.location_network.description	
	end	

	# Indexes
	index({ report_entity_id: 1 }, { name: "report_entity_index" })
end
