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
	field :total_quantity, type: Integer				  	
	field :fact_time, :type => Time

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

		response = AssetSummaryFact.where(params).between(fact_time: start_date..end_date).desc(:fact_time).map { |asset_summary_fact| {
																				:date => asset_summary_fact.fact_time.in_time_zone("Central Time (US & Canada)").strftime("%b %d, %Y"),
																				:location_network => asset_summary_fact.location_network_description,
																				:location_network_id => asset_summary_fact.location_network_id,
																				:asset_type => asset_summary_fact.asset_type_description,
																				:sku => asset_summary_fact.sku_description,		
																				:sku_id => asset_summary_fact.sku_id,
																				:date_id => asset_summary_fact.fact_time.to_i,
																				:product => asset_summary_fact.product_description,
																				:product_entity => asset_summary_fact.product_entity_description,
																				:empty_quantity => asset_summary_fact.empty_quantity,
																				:full_quantity => asset_summary_fact.full_quantity,
																				:market_quantity => asset_summary_fact.market_quantity,
																				:total_quantity => asset_summary_fact.total_quantity
																			}
																		}
		return response

	end

	  
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

		self.total_quantity = self.empty_quantity + self.full_quantity + self.market_quantity

	end	

	# Indexes
	index({ report_entity_id: 1 }, { name: "report_entity_index" })
end
