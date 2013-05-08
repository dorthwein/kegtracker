class DailyFact
	include Mongoid::Document
	include Mongoid::Timestamps  	

# Dimensions	
	# Primary 
		belongs_to :location
		belongs_to :asset_entity, :class_name => 'Entity' 	# Asset Owner
		belongs_to :product
		belongs_to :asset_type, :class_name => 'AssetType' 
		field :asset_status, type: Integer

		field :fact_time, type: Time
	
	# Secondary
		belongs_to :location_entity, :class_name => 'Entity'
		belongs_to :location_network, :class_name => 'Network'
		field :location_network_type, type: Integer
		belongs_to :product_entity, :class_name => 'Entity'	

		field :entity_state, type: String
		field :entity_city, type: String
	
	# Dimension Descriptions
		field :location_description, type: String
		field :asset_entity_description, type: String
		field :product_description, type: String
		field :asset_type_description, type: String
		field :asset_status_description, type: String
		field :location_entity_description, type: String
		field :location_network_description, type: String
		field :product_entity_description, type: String

	# Facts
		field :quantity
		field :case_equivalent

		field :total_quantity			# Total of Visibile Assets
		field :case_equivalent_total	# Total of Visibile Assets
		field :days_at_location_sample_size
		field :days_at_location_avg
		field :avg_time_at_entity


	before_save :sync_descriptions	
	def sync_descriptions
	# Secondary Dimensions
		self.location_network_id = self.location.network_id rescue nil		
		self.product_entity_id = self.product.entity_id rescue nil
		self.location_entity_id = self.location.entity_id rescue nil
		self.entity_state = self.location_entity.state rescue nil
		self.entity_city = self.location_entity.city rescue nil

	# Descriptions	
		self.location_description = self.location.description 
		self.asset_entity_description = self.asset_entity.description 
		self.asset_status_description = self.get_asset_status_description

		self.product_description = self.asset_status.to_i == 0 ? 'Empty' : self.product.description
		self.product_entity_description = self.asset_status.to_i == 0 ? 'Empty' : self.product_entity.description

		self.asset_type_description = self.asset_type.description 
		self.location_entity_description = self.location_entity.description 
		self.location_network_description = self.location_network.description 
	


	end	
	def get_asset_status_description
		case self.asset_status.to_i
		when 0
			return 'Empty'	
		when 1
			return 'Full'	
		when 2
			return 'Market'	
#		when 3
#			return 'Damaged'	
#		when 4
#			return 'Lost'	
#		else
#			return 'Unknown'	
		end
	end
	

end

