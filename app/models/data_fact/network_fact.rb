class NetworkFact
	include Mongoid::Document
	include Mongoid::Timestamps  	

	belongs_to :report_entity, :class_name => 'Entity'  		# Who owns the report	
	belongs_to :location_network, :class_name => 'Network'	

	belongs_to :product  
	belongs_to :asset_type 
	belongs_to :product_entity, :class_name => 'Entity'	

	field :location_network_type, 					type: Integer
	field :location_network_type_description, 		type: String

	field :location_network_description, 			type: String
	field :product_entity_description, 				type: String # AKA Brewery	
	field :product_description,						type: String
	field :fact_time, 								type: Time
	field :asset_type_description, 					type: String
	
	field :sku_description, 						type: String
	field :sku_id, 									type: String

# Asset Activity Summary Fact
	field :fill_quantity,						 	type: Integer, :default => 0
	field :delivery_quantity, 						type: Integer, :default => 0
	field :pickup_quantity, 						type: Integer, :default => 0
	field :move_quantity, 							type: Integer, :default => 0

# Asset Summary Fact
	field :empty_quantity, 							type: Integer, :default => 0
	field :full_quantity, 							type: Integer, :default => 0
	field :market_quantity, 						type: Integer, :default => 0
	field :total_quantity, 							type: Integer, :default => 0

# Fill to Fill Cycle by Network
	field :life_cycle_max_time, 					:type => Integer, :default => 0
	field :life_cycle_avg_time, 					:type => Integer, :default => 0
	field :life_cycle_min_time, 					:type => Integer, :default => 0
	field :life_cycle_completed_cycles, 			:type => Integer, :default => 0

# In bound Out Bound by Network
	field :in_full_quantity, 						type: Integer, :default => 0
	field :in_market_quantity, 						type: Integer, :default => 0
	field :in_empty_quantity, 						type: Integer, :default => 0
	field :in_total_quantity, 						type: Integer, :default => 0				  

	field :out_full_quantity, 						type: Integer, :default => 0				  
	field :out_market_quantity, 					type: Integer, :default => 0				  
	field :out_empty_quantity, 						type: Integer, :default => 0				  
	field :out_total_quantity, 						type: Integer, :default => 0				  


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

		self.location_network_description = self.location_network.description	

		self.product_description = self.product.description	
		self.product_entity = self.product.entity		
		self.product_entity_description = self.product.nil? ? 'Unknown' : self.product_entity.description	

		self.location_network_type = self.location_network.network_type rescue nil
		self.location_network_type_description = self.location_network.get_network_type_description rescue nil
	end	
end
