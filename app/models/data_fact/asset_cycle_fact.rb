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
	belongs_to :product_entity, class_name: 'Entity'
	belongs_to :asset_type
  	belongs_to :asset, index: true  
  
	field :start_time, type: Time
	field :fill_time, type: Time
	field :delivery_time, type: Time
	field :pickup_time, type: Time
	field :end_time, type: Time
# TBI	field :return_to_brewery_time, type: Time
	
	field :batch_number, type: String
	
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
	field :cycle_complete_description, type: String, default: 'No'
	# 0 = Bad Quality
	# 1 = Good Quality - Fill, Delivery, & Pickup
	field :cycle_quality, type: Integer, default: 0
		  
  	belongs_to :start_network, class_name: 'Network'
  	belongs_to :fill_network, class_name: 'Network'
  	belongs_to :delivery_network, class_name: 'Network'
  	belongs_to :pickup_network, class_name: 'Network'
	belongs_to :end_network, class_name: 'Network'

	field :start_network_description, type: String
	field :fill_network_description, type: String
	field :delivery_network_description, type: String
	field :pickup_network_description, type: String
	field :end_network_description, type: String
	field :product_description, type: String
	field :product_entity_description, type: String
	field :asset_type_description, type: String
	field :asset_status_description, type: String
	field :handle_code_description, type: String

# TBI  	belongs_to :return_to_brewery_network, class_name: 'Network'
  	

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
  		print 'BATCH FUCK' + asset_activity_fact.batch_number.to_s
  		self.batch_number = asset_activity_fact.batch_number
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
	  	if !self.start_time.nil? && !self.fill_time.nil? && !self.delivery_time.nil? && !self.pickup_time.nil? && !self.end_time.nil? && !self.product.nil? && !self.asset_type.nil? 
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


		# Check Descriptions		
		self.product_entity = self.product.entity
		self.product_entity_description = self.product_entity.description
		
		self.product_description = self.product.description				
		self.asset_type_description = self.asset_type.description	

		if self.cycle_complete == 1
			self.cycle_complete_description = 'Yes'
		else
			self.cycle_complete_description = 'No'
		end
		
		self.start_network_description = self.start_network.description
		self.fill_network_description = self.fill_network.description
		self.delivery_network_description = self.delivery_network.description
		self.pickup_network_description = self.pickup_network.description
		self.end_network_description = self.end_network.description
	end
	def get_asset_status_description
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

	def self.build_cycle_facts_from_time_line
		i = 0 
		AssetActivityFact.all.asc(:fact_time).each do |x|
			i = i + 1
			
			case x.handle_code.to_i
		    when 1
				n = AssetCycleFact.where(asset_id: x.asset_id).lte(start_time: x.fact_time).desc(:start_time).first
				if !n.nil?
					n.delivery_time = x.fact_time
				  	n.delivery_asset_activity_fact_id = x._id
			  		n.delivery_network_id = x.location_network_id
			  		n.save!

					x.asset_cycle_fact_id = n._id
					x.save!
				end
		    when 2
				n = AssetCycleFact.where(asset_id: x.asset_id).lte(start_time: x.fact_time).desc(:start_time).first
				if !n.nil?
					n.pickup_time = x.fact_time
				  	n.pickup_asset_activity_fact_id = x._id
			  		n.pickup_network_id = x.location_network_id
			  		n.save!

					x.asset_cycle_fact_id = n._id
					x.save!
				end
#			      return 'Pickup'
		    when 4
				# If a fill, find this asset's previous cycle fact and end it
				t = AssetCycleFact.where(asset_id: x.asset_id, :start_asset_activity_fact_id.ne => x._id).lte(start_time: x.fact_time).desc(:start_time).first
				if !t.nil?
					t.end_time = x.fact_time
				  	t.end_asset_activity_fact_id = x._id
			  		t.end_network_id = x.location_network_id
					t.cycle_complete = 1
					t.completed_cycle_length = (t.end_time.to_i - t.start_time.to_i)				
					t.save!
#					print t.start_time.to_s + ' -- ' + x.fact_time.to_s + ' -- ' + "Found Cycle - ending it \n"
				end

				# Find or Create new cycle
				n = AssetCycleFact.where(asset_id: x.asset_id).lte(start_time: x.fact_time).desc(:start_time).find_or_create_by(:start_asset_activity_fact_id => x._id)
				
			  	n.asset_id = x.asset_id
			  	n.asset_type_id = x.asset_type_id
			  	n.entity_id = x.entity_id
			  	n.product_id = x.product_id
			  	n.fill_count = x.fill_count.to_i

				n.start_time = x.fact_time
				n.start_asset_activity_fact_id = x._id
				n.start_network_id = x.location_network_id
				
				n.fill_time = x.fact_time
				n.fill_asset_activity_fact_id = x._id
				n.fill_network_id = x.location_network_id
				n.save!

				x.asset_cycle_fact_id = n._id
				x.save!
			when 5
				n = AssetCycleFact.where(asset_id: x.asset_id).lte(start_time: x.fact_time).desc(:start_time).first
				if !n.nil?
					x.asset_cycle_fact_id = n._id
					x.save!
				end
		    end			
		end

		i = 0
		Asset.all.each do |x|
			n = AssetCycleFact.where(asset_id: x._id).desc(:start_time).first._id
			if !n.nil?
				x.asset_cycle_fact_id = AssetCycleFact.where(asset_id: x._id).desc(:start_time).first._id
				x.fill_time = x.asset_cycle_fact.fill_time
				x.save!
			else 
				i = i + 1

			end
		end
	end
	def get_handle_code_description
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
