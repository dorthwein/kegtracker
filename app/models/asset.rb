class Asset
  include Mongoid::Document
  include Mongoid::Timestamps  
	
# Fixed Details
	field :netid, type: Integer
	field :tag_value, type: String
	field :tag_key, type: String
	field :fill_count, type: Integer, :default => 0

	belongs_to :asset_activity_fact

	belongs_to :asset_type
	field :asset_type_description, type: String	

	belongs_to :network		# Tag Network
	field :network_description, type: String	
	
	belongs_to :entity		# Tag Owner	
	field :entity_description, type: String			
	
# Variable Details
	belongs_to :product	
	field :product_description, type: String		
	field :product_entity_description, type: String # AKA Brewery

#	belongs_to :asset_state	
#	field :asset_state_description, type: String			
	
	# asset status: 0 = Empty, 1 = Full, 2 = In Market
	field :asset_status, type: Integer, :default => 0
	field :asset_status_description, type: String

	field :location_description, type: String			
	belongs_to :location
	
	field :location_network_description, type: String		
	belongs_to :location_network, :class_name => 'Network'				
	
	field :handle_code, type: Integer

	field :user_email_description, type: String				
	belongs_to :user
	

# Relations	
	# Life Cycle
	field :last_action_time, :type => Time

	field :fill_time, :type => Time
	belongs_to :fill_location, :class_name => 'Location'
	field :fill_location_description, type: String	
	belongs_to :fill_network, :class_name => 'Network'
	field :fill_network_description, type: String	

	field :delivery_time, :type => Time
	belongs_to :delivery_location, :class_name => 'Location'
	field :delivery_location_description, type: String	
	belongs_to :delivery_network, :class_name => 'Network'	
	field :delivery_network_description, type: String	


	field :pickup_time, :type => Time
	belongs_to :pickup_location, :class_name => 'Location'
	field :pickup_location_description, type: String	
	belongs_to :pickup_network, :class_name => 'Network'	
	field :pickup_network_description, type: String	

	# Set before all actions to detect if the asset should have "Smart Actions" applied to it.
	def smart_network_processing options
		to_network = Location.find(options[:to_location]).network
		if self.location_network_id != to_network._id		
			print "Smart Network Processing \n"
		# Effects at From Network
		### OUTBOUND ####
		# Asset Leaving a brewery		
			if self.location_network.network_type_id == 1 && self.asset_status != 1
				# Fill Asset at Outbound Location
				opt = {
						:product => self.location_network.smart_mode_product,
						:location => self.location_network.smart_mode_out_location._id,
						:correction => options[:correction],
						:time => options[:time]
					}
				self.fill(opt)			
			end

			# Asset leaving a distributor/market pickup at Outbound Location
			if (self.location_network.network_type_id == 2 || self.location_network.network_type_id == 3) && to_network.network_type_id == 1 && self.asset_status != 0
				opt = {
						:location => self.location_network.smart_mode_out_location._id,
						:correction => options[:correction],
						:time => options[:time]
					}
				self.pickup(opt)

			end

			### INBOUND ###			
			# Asset Arriving at Production Facility - Empty asset, purge other entity product
			if to_network.network_type_id == 1
				# Needs to be changed to check for Authorized products
				if to_network.entity != self.product.entity
					self.product = nil
				end
				opt = {
						:location => self.location_network.smart_mode_out_location._id,
						:correction => options[:correction],
						:time => options[:time]
					}
				self.pickup(opt)
			end
		end
	end
	
	def deliver options
		# Options: time, location, correction		
		self.handle_code = 1
		self.asset_status = 2
		print options[:time].to_s + "<--- \n" 
		
		self.last_action_time = options[:time]		
		self.location_id = options[:location]
		
		self.delivery_time = options[:time]
		self.delivery_location_id = options[:location]				
		self.create_asset_activity_fact(:correction => options[:correction])
	end	

	def pickup options
		# Options: time, location, correction
		self.handle_code = 2
		self.asset_status = 0		
		self.last_action_time = options[:time]
		
		self.location_id = options[:location]
		
		self.pickup_time = options[:time]
		self.pickup_location_id = options[:location]
		self.create_asset_activity_fact(:correction => options[:correction])
	end

	def add	options
		# Options: time, location, correction		
		self.handle_code = 3
		self.asset_status = 0		
		self.last_action_time = options[:time]

		self.location_id = options[:location]
		self.create_asset_activity_fact(:correction => options[:correction])
	end
	
	def fill options
		# Options: time, location, product, correction
		self.handle_code = 4		
		self.asset_status = 1

		self.last_action_time = options[:time]				
		
		self.location_id = options[:location]

		self.product_id = options[:product]
		self.fill_time = options[:time]
		self.fill_location_id = options[:location]
		
		# If not correction
		if !options[:correction]
			self.fill_count = self.fill_count.to_i + 1
		end
		self.create_asset_activity_fact(:correction => options[:correction])
	end

	def move options
		# Options: time, location, correction
		self.handle_code = 5
		self.last_action_time = options[:time]
		self.location_id = options[:location]
		self.create_asset_activity_fact(:correction => options[:correction])
	end

	def rfnet options
		# Options: time, location, correction
		if self.location_network != Location.find(options[:location]).network
			self.handle_code = 5	# Records as a move
			self.last_action_time = options[:time]
			self.location_id = options[:location]
			self.create_asset_activity_fact(:correction => options[:correction])
		end
	end	

	def audit options
		# HC = 7
	end

	def create_asset_activity_fact options
		# Options: correction
		asset_activity_fact_details = {
									:asset_id => self._id,
									:asset_status => self.asset_status,
									:asset_type_id => self.asset_type_id,																		
									:entity_id => self.entity_id,

									:product_id => self.product_id,
									:handle_code => self.handle_code.to_i,
									
									:fact_time => self.last_action_time,
									:fill_count => self.fill_count.to_i,
									
									:location_id => self.location_id,
									:location_network_id => self.location_network_id,

									# :network => self.network, Possible Depricated
#									:fill_network => self.fill_network,
									:user => self.user,
#									:fill_time => @asset.fill_time,								
								}
		fact = AssetActivityFact.where(:_id => self.asset_activity_fact._id).first
		if options[:correction] && !fact.nil?		
			fact.update_attributes(asset_activity_fact_details)
			print " \n \n"	
			print fact.to_json
			print " \n \n"	
			print "Fact Change \n \n"	
		else	
			asset_activity_fact = AssetActivityFact.new(asset_activity_fact_details)
			self.asset_activity_fact = asset_activity_fact
			asset_activity_fact.save
			
			print "New Fact \n \n"	
		end
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

	before_save :sync_descriptions	
	def sync_descriptions
		# Ensure location_network is correct	
		self.asset_activity_fact = AssetActivityFact.where(:asset => self).desc(:fact_time).first
		if self.asset_activity_fact.nil?
			if self.last_action_time.nil?
				time = Time.new()
			else
				time = self.last_action_time
			end
			opt = {
					:location => self.location._id,
					:correction => false,
					:time => time
				}
			self.move(opt)

		end
		self.location_network = self.location.network		

		# Check Descriptions
		self.network_description = self.network.description
		self.entity_description = self.entity.description	
		self.product_description = self.product.description
		
		self.product_entity_description = self.product.nil? ? ' ' : self.product.entity.description	

		self.asset_type_description = self.asset_type.description	
#		self.asset_state_description = self.asset_state.description	
		
		
		self.location_description = self.location.description	
		self.location_network_description = self.location_network.description	
		
		self.fill_network_description = self.fill_network.description
		self.pickup_network_description = self.pickup_network.description
	end	

	# Indexes
	index({ location_network_id: 1 }, { name: "location_network_index" })
	index({ product_id: 1 }, { name: "product_index" })
	index({ entity_id: 1 }, { name: "entity_index" })	
end