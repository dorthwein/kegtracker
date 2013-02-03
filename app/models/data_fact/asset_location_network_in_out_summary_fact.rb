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

	def sku_id
		return 'prod_' + self.product_id.to_s + '_type_' + self.asset_type_id.to_s
	end

	def sku_description
		return self.product_description.to_s + ' - ' + self.asset_type_description
	end
	def location_network_asset_type_id
		return 'net_' + self.location_network_id.to_s + '_type_' + self.asset_type_id.to_s
	end

	def self.grid_facts options = {}  	
    	if options[:start_date].nil? || options[:end_date].nil?
    		start_date = Time.new().in_time_zone("Central Time (US & Canada)").beginning_of_day
    		end_date = Time.new().in_time_zone("Central Time (US & Canada)").end_of_day
    	else
    		start_date = options[:start_date].beginning_of_day
    		end_date = options[:end_date].end_of_day
    	end

    	params = {:report_entity => options[:entity]}
    	if !options[:location_network].nil?
    		params[:location_network] = options[:location_network]
    	end

		response = AssetLocationNetworkInOutSummaryFact.where(params).between(fact_time: start_date..end_date).desc(:fact_time).map { |x| {
																				:date => x.fact_time.in_time_zone("Central Time (US & Canada)").strftime("%b %d, %Y"),
																				:location_network =>		x.location_network_description,
																				:location_network_asset_type_id => 	x.location_network_asset_type_id,
																				:asset_type => 				x.asset_type_description,
																				:asset_type_id => 				x.asset_type_id,
																				:product => 				x.product_description,
																				:product_entity => 			x.product_entity_description,
																				:sku => 					x.sku_description,
																				:sku_id => 					x.sku_id,
																				:date_id => 				x.fact_time.to_i,
																				:in_total_quantity => 		x.in_total_quantity,
																				:out_total_quantity => 		x.out_total_quantity
			}
		}		
		return response

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
