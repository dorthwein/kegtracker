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
	belongs_to :product_entity, :class_name => 'Entity'	
	


# Product
  	belongs_to :product  

# Asset Details
  	belongs_to :asset_type 
#	field :asset_status, type: Integer
	field :handle_code, type: Integer  




# Location
# Activity
# Reporting
# DE-NORMALIZED
	field :location_network_description, type: String
	
	field :asset_type_description, type: String
	field :product_description, type: String

	field :handle_code_description, type: String
	field :product_entity_description, type: String # AKA Brewery

	def self.grid_facts options = {}  	

    	if options[:start_date].nil? || options[:end_date].nil?
    		start_date = Time.new().in_time_zone("Central Time (US & Canada)").beginning_of_day
    		end_date = Time.new().in_time_zone("Central Time (US & Canada)").end_of_day
    	else
    		start_date = options[:start_date].beginning_of_day
    		end_date = options[:end_date].end_of_day
    	end

    	params = {:report_entity => options[:entity]}
#    	if !options[:location_network].nil?
 #   		params[:location_network] = options[:location_network]
  #  	end

		response = AssetActivitySummaryFact.where(params).between(fact_time: start_date..end_date).desc(:fact_time).map { |asset_summary_fact| {
																				:date => asset_summary_fact.fact_time.in_time_zone("Central Time (US & Canada)").strftime("%b %d, %Y"),
																				:location_network => asset_summary_fact.location_network_description,
																				:location_network_id => asset_summary_fact.location_network_id,
																				:asset_type => asset_summary_fact.asset_type_description,
																				:sku => asset_summary_fact.sku_description,		
																				:sku_id => asset_summary_fact.sku_id,
																				:date_id => asset_summary_fact.fact_time.to_i,
																				:handle_code_id => asset_summary_fact.handle_code.to_i,
																				:handle_code_description => asset_summary_fact.handle_code_description,
																				:product => asset_summary_fact.product_description,
																				:product_entity => asset_summary_fact.product_entity_description,
																				:quantity => asset_summary_fact.quantity
																			}
																		}
		return response

	end

	def handle_code_description
		case self.handle_code.to_i
		when 1
		  return 'Delivery' 
		when 2
		  return 'Pickup'
		when 3
		  return 'Add'
		when 4
		  return 'Fill'
		when 5
		  return 'Move'
		when 6
		  return 'RFNet'
		when 7
		  return 'Audit'
		end
	end

	def sku_id
		return 'prod_' + self.product_id.to_s + '_type_' + self.asset_type_id.to_s
	end

	def sku_description
		return self.product_description.to_s + ' - ' + self.asset_type_description
	end
	
	before_save :sync
	def sync
		self.asset_type_description = self.asset_type.description		
		self.product_description = self.product.description	
		self.location_network_description = self.location_network.description			

		self.product_entity = self.product.entity		
		self.product_entity_description = self.product.nil? ? 'Unknown' : self.product_entity.description	

	end
	# Indexes
	index({ report_entity_id: 1 }, { name: "report_entity_index" })	
end
