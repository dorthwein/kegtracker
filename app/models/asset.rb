class Asset
  include Mongoid::Document
  include Mongoid::Timestamps  
  include ExtendMongoid
  # 1 = Active, 0 = Deleted, 
	field :record_status, type: Integer, default: 1	

# Instead of changing key values - simply change key mapping before send 
# harder on the system easier on bandwidth

# Fixed Details
	field :netid, type: Integer
	field :tag_value, type: String
	field :tag_key, type: String
	field :fill_count, type: Integer, :default => 0

	belongs_to :asset_activity_fact
	belongs_to :asset_cycle_fact

	belongs_to :asset_type
	field :asset_type_description, type: String	
	belongs_to :sku

	belongs_to :network		# Tag Network
	field :network_description, type: String	
	
	belongs_to :entity, index: true		# Tag Owner	
	field :entity_description, type: String			
	
# Variable Details
	belongs_to :invoice, index: true
	belongs_to :invoice_detail, index: true

	belongs_to :invoice_attached_asset, index: true

	field :invoice_number, type: String

	field :batch_number, type: String

	belongs_to :product, index: true	
	field :product_description, type: String		

	belongs_to :product_entity, :class_name => 'Entity', index: true
	field :product_entity_description, type: String # AKA Brewery
	
	# Asset Status: 0 = Empty, 1 = Full, 2 = In Market
	field :asset_status, type: Integer, :default => 0
	field :asset_status_description, type: String			

	field :asset_overdue,		type: Integer, :default => 0
	field :asset_damaged,		type: Integer, :default => 0
	field :asset_lost,			type: Integer, :default => 0

	field :location_description, type: String				
	belongs_to :location, index: true
	field :days_at_location, type: Integer

	field :location_network_description, type: String		
	belongs_to :location_network, :class_name => 'Network', index: true

	field :location_entity_description, type: String
	belongs_to :location_entity, :class_name => 'Entity'
	field :location_entity_arrival_time, type: Time

	field :handle_code, type: Integer
	field :handle_code_description, type: String

	field :user_email_description, type: String				
	belongs_to :user
	
	belongs_to :production_invoice, :class_name => 'Invoice' 	# Not Active
	field :production_invoice_number, type: String				# Not Active

# Relations	
	# Life Cycle
	field :last_action_time, :type => Time
	field :fill_time, :type => Time


#	belongs_to :fill_location, :class_name => 'Location'
#	field :fill_location_description, type: String	
#	belongs_to :fill_network, :class_name => 'Network'
#	field :fill_network_description, type: String	

	def move options
		# Options: time, location, correction
		if options[:handle_code].to_i == 6
			if self.location_network != Location.find(options[:location_id]).network
				self.last_action_time = options[:time]
				self.location_id = options[:location_id]
				self.asset_activity_fact = AssetActivityFact.create_from_asset(self)
				self.asset_activity_fact.save!
				print "RFNet Catch \n"
			end
		else			
			print "Not RF \n"			
			self.last_action_time = options[:time]			# Required
			self.location_id = options[:location_id]		# Required
			self.user_id = options[:user_id]

			options[:asset_type_id].nil? ? nil : self.asset_type_id = options[:asset_type_id] 					# If not nil					
			options[:batch_number].nil? ? nil : self.batch_number = options[:batch_number]
			options[:product_id].nil? ? nil : self.product_id = options[:product_id] 							# If not nil

			unless options[:product_id].nil?
				self.fill_time = options[:time]
			end

			self.asset_activity_fact = AssetActivityFact.create_from_asset(self)
			self.asset_activity_fact.save!

			self.save!
		end
#		self.add_to_invoice(options)
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
		else
			self.delete
		end
	end
	
	def set_asset_status
		unless self.location.nil?
		  case self.location.location_type 
		  when 1
		    self.asset_status = 1
		  when 2
		    self.asset_status = 0
		  when 3
		    self.asset_status = 2
		  end 
		else 
		  self.delete
		end
	end

	def calc_days_at_location
		# in days
		if self.last_action_time
			return (Time.new.to_i - self.last_action_time.to_i)/86400
		else
			return ' '
		end
	end

	before_save :sync_descriptions
	def sync_descriptions
		self.sku = Sku.find_or_create_by(entity: self.product.entity, primary_asset_type: self.asset_type, product: self.product)
		self.invoice_number = self.invoice.invoice_number rescue nil
		
		self.location_network = self.location.network		
		self.location_entity = self.location.entity

		self.set_asset_status
		self.asset_status_description = self.get_asset_status_description

#		self.fill_network = self.fill_location.network		
		self.product_entity = self.product.entity rescue nil

		# Check Descriptions
		self.network_description = self.network.description
		self.entity_description = self.entity.description	

		if self.asset_status.to_i == 0
			self.product = nil
			self.batch_number = nil
			self.invoice_number = nil
			self.invoice = nil
		end
		self.product_description = self.asset_status.to_i == 0 ? 'Empty' : self.product.description
		self.product_entity_description = self.asset_status.to_i == 0 ? 'Empty' : self.product_entity.description

		self.asset_type_description = self.asset_type.description	

#		self.handle_code_description = self.get_handle_code_description
		self.location_description = self.location.description	
		self.location_network_description = self.location_network.description			

		self.days_at_location = self.calc_days_at_location		
		self.location_entity_description = self.location_entity.description	
		self.asset_overdue = 0
		
		if self.asset_activity_fact
			self.location_entity_arrival_time = self.asset_activity_fact.location_entity_arrival_time
		else
			self.location_entity_arrival_time = self.last_action_time
		end		
	end	

	after_save :after_save
	def after_save
		self.location.save rescue nil
	end
	# Indexes
	index({ location_network_id: 1 }, { name: "location_network_index" })
	index({ product_id: 1 }, { name: "product_index" })
	index({ entity_id: 1 }, { name: "entity_index" })	
end








