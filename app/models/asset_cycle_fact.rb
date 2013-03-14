class AssetCycleFact
  include Mongoid::Document
  include Mongoid::Timestamps  	
	field :record_status, type: Integer, default: 1

	
# Created in Scan Object
# Used by report builder to generate report facts

	has_many :asset_activity_facts
# Fact Details 
	belongs_to :entity, index: true      # Asset Owner
	belongs_to :product, index: true		# Asset Product
	belongs_to :asset_type
  	belongs_to :asset, index: true  
  
	field :start_time, type: Time
	field :fill_time, type: Time
	field :delivery_time, type: Time
	field :pickup_time, type: Time
# TBI	field :return_to_brewery_time, type: Time
	field :end_time, type: Time
	
	belongs_to :start_asset_activity_fact, class_name: 'AssetActivityFact' #, 		:inverse_of => 'AssetActivityFact'
  	belongs_to :fill_asset_activity_fact, class_name: 'AssetActivityFact' #, 		:inverse_of => 'AssetActivityFact'
  	belongs_to :pickup_asset_activity_fact, class_name: 'AssetActivityFact' #, 	:inverse_of => 'AssetActivityFact'
  	belongs_to :delivery_asset_activity_fact, class_name: 'AssetActivityFact' #, 	:inverse_of => 'AssetActivityFact'
# TBI	belongs_to :return_to_brewery_asset_activity_fact, class_name: 'AssetActivityFact' #, 	:inverse_of => 'AssetActivityFact'
	belongs_to :end_asset_activity_fact, class_name: 'AssetActivityFact' #, 		:inverse_of => 'AssetActivityFact'  	

	field :cycle_networks, type: Array

	field :fill_count, type: Integer
#  	field :cycle_length, type: Integer, default: 0
  	field :completed_cycle_length, type: Integer, default: 0

	field :cycle_complete, type: Integer, default: 0 # yes/no	

	# 0 = Bad Quality
	# 1 = Good Quality - Fill, Delivery, & Pickup
	field :cycle_quality, type: Integer, default: 0
		  
  	belongs_to :start_network, class_name: 'Network'
  	belongs_to :fill_network, class_name: 'Network'
  	belongs_to :delivery_network, class_name: 'Network'
  	belongs_to :pickup_network, class_name: 'Network'
# TBI  	belongs_to :return_to_brewery_network, class_name: 'Network'
  	belongs_to :end_network, class_name: 'Network'

#  	belongs_to :fill_user, class_name:'User', inverse_of: 'User'
# 	belongs_to :delivery_user, class_name: 'User', inverse_of: 'User'
#  	belongs_to :pickup_user, class_name: 'User', inverse_of: 'User'

	def general_attributes asset_activity_fact
	  	if !self.start_time.nil? && !self.fill_time.nil? && !self.delivery_time.nil? && !self.pickup_time.nil? && !self.end_time.nil? 
			self.cycle_quality = 1	  		
	  	else
			self.cycle_quality = 0
	  	end
	end

	def start asset_activity_fact
		self.start_time = asset_activity_fact.fact_time
		self.start_asset_activity_fact = asset_activity_fact
		self.start_network = asset_activity_fact.location_network

		self.general_attributes asset_activity_fact
#		print asset_activity_fact.asset_cycle_fact.class

		self.save!

	end

	def fill asset_activity_fact	
		self.fill_time = asset_activity_fact.fact_time
	  	self.fill_asset_activity_fact = asset_activity_fact
  		self.fill_network = asset_activity_fact.location_network
		
		self.general_attributes asset_activity_fact

		self.save!
	end
	
	def deliver asset_activity_fact								
		self.delivery_time = asset_activity_fact.fact_time
	  	self.delivery_asset_activity_fact = asset_activity_fact
  		self.delivery_network = asset_activity_fact.location_network

  		self.general_attributes asset_activity_fact
		
  		self.save!
	end

	def pickup asset_activity_fact
		self.pickup_time = asset_activity_fact.fact_time
	  	self.pickup_asset_activity_fact = asset_activity_fact
  		self.pickup_network = asset_activity_fact.location_network

		self.general_attributes asset_activity_fact

		self.save!
	end

	def move asset_activity_fact

	end

	def end asset_activity_fact
		self.end_time = asset_activity_fact.fact_time
	  	self.end_asset_activity_fact = asset_activity_fact
  		self.end_network = asset_activity_fact.location_network
  		
		self.cycle_complete = 1
		self.completed_cycle_length = (self.end_time.to_i - self.start_time.to_i)

		self.save!
	end

	def self.create_by_asset asset
		details = {
	      :asset => asset,
		  :asset_type => asset.asset_type,
	      :entity => asset.entity,
	      :product => asset.product,
	      :fill_count => asset.fill_count.to_i,
		}
		asset_cycle_fact = AssetCycleFact.create(details)
		asset_cycle_fact.start(asset.asset_activity_fact)

		asset_cycle_fact.save!
		return asset_cycle_fact
	end

	before_save :sync
	def sync
	  	if !self.start_time.nil? && !self.fill_time.nil? && !self.delivery_time.nil? && !self.pickup_time.nil? && !self.end_time.nil? 
			self.cycle_quality = 1	  		
	  	else
			self.cycle_quality = 0
	  	end
	  	if self.cycle_complete == 1
	  		self.completed_cycle_length = (self.end_time.to_i - self.start_time.to_i)
	  	end	  		  	
	  	self.cycle_networks = [
  			self.start_network_id,
  			self.fill_network_id,
  			self.delivery_network_id,
#  			self.pickup_network_id,
#  			self.end_network_id
	  	].delete_if {|x| x == nil}
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
end
