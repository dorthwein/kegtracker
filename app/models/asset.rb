class Asset
  include Mongoid::Document
  include Mongoid::Timestamps  
	field :record_status, type: Integer, default: 1	

# Instead of changing key values - simply change key mapping before send 
# harder on the system easier on bandwidth
#
#
#
#

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

	belongs_to :product, index: true	
	field :product_description, type: String		

	belongs_to :product_entity, :class_name => 'Entity', index: true
	field :product_entity_description, type: String # AKA Brewery
	
	# asset status: 0 = Empty, 1 = Full, 2 = In Market
	field :asset_status, type: Integer, :default => 0
	field :asset_status_description, type: String

	field :location_description, type: String			
	belongs_to :location, index: true
	
	field :location_network_description, type: String		
	belongs_to :location_network, :class_name => 'Network', index: true
	
	field :handle_code, type: Integer
	field :handle_code_description, type: String

	field :user_email_description, type: String				
	belongs_to :user
	
	belongs_to :production_invoice, :class_name => 'Invoice'
	field :production_invoice_number, type: String

# Relations	
	# Life Cycle
	field :last_action_time, :type => Time
	field :fill_time, :type => Time
	belongs_to :fill_location, :class_name => 'Location'
	field :fill_location_description, type: String	
	belongs_to :fill_network, :class_name => 'Network'
	field :fill_network_description, type: String	

=begin
# Not active
	field :delivery_time, :type => Time
	belongs_to :delivery_location, :class_name => 'Location'
	field :delivery_location_description, type: String	
	belongs_to :delivery_network, :class_name => 'Network'	
	field :delivery_network_description, type: String	

# Not active
	field :pickup_time, :type => Time
	belongs_to :pickup_location, :class_name => 'Location'

	field :pickup_location_description, type: String	
	belongs_to :pickup_network, :class_name => 'Network'	
	field :pickup_network_description, type: String
=end
=begin
# To be moved to invoice
	def add_to_invoice options
		print '->' 
		invoice = Invoice.where(:_id => options[:invoice_id]).first
		if !invoice.nil?	
			print "\n \n"	
			print 'Adding to Invoice'
			print "\n \n"
			invoice = Invoice.find(options[:invoice_id]) 
			
			print invoice.to_json
			print "\n \n"
		
			self.invoice_attached_asset = invoice.add_invoice_asset_detail({:asset => self, :asset_activity_fact => self.asset_activity_fact})
		end
	end
=end

	def deliver options
		# Options: time, location, correction, invoice
		self.handle_code = 1
		self.asset_status = 2
		
		self.last_action_time = options[:time]		
		self.location_id = options[:location_id]
		
#		self.delivery_time = options[:time]
#		self.delivery_location_id = options[:location_id]				
				
		self.asset_activity_fact = AssetActivityFact.create_from_asset(self)		
		self.asset_cycle_fact.deliver(self.asset_activity_fact) rescue (
			self.asset_cycle_fact = AssetCycleFact.create_by_asset(self)
			self.asset_cycle_fact.deliver(self.asset_activity_fact)
		)
		self.asset_activity_fact.asset_cycle_fact_id = self.asset_cycle_fact._id
		self.asset_activity_fact.save!

#		self.process_asset_cycle_fact(options)	# - To be moved
#		self.add_to_invoice(options) # - To be moved
	end	

	def pickup options
		# Options: time, location, correction, invoice
		self.handle_code = 2
		self.asset_status = 0		
		self.last_action_time = options[:time]
		
		self.location_id = options[:location_id]
		
#		self.pickup_time = options[:time]
#		self.pickup_location_id = options[:location_id]
				
		self.asset_activity_fact = AssetActivityFact.create_from_asset(self)						

		self.asset_cycle_fact.pickup(self.asset_activity_fact) rescue (
			self.asset_cycle_fact = AssetCycleFact.create_by_asset(self)
			self.asset_cycle_fact.pickup(self.asset_activity_fact)
		)
		
		self.asset_activity_fact.asset_cycle_fact_id = self.asset_cycle_fact._id
		self.asset_activity_fact.save!

#		self.process_asset_cycle_fact(options)
#		self.add_to_invoice(options)
	end

	def fill options
		# Options: time, location_id, product_id, correction
		if !self.asset_activity_fact.nil? && !self.asset_cycle_fact.nil?
			self.asset_cycle_fact.end(self.asset_activity_fact)
		end
		

		self.handle_code = 4		
		self.asset_status = 1
		self.last_action_time = options[:time]				
		self.location_id = options[:location_id]
		self.product_id = options[:product_id]
		self.fill_time = options[:time]
		self.fill_location_id = options[:location_id]	
		self.fill_count = self.fill_count.to_i + 1	


		self.asset_activity_fact = AssetActivityFact.create_from_asset(self)		
		self.asset_cycle_fact = AssetCycleFact.create_by_asset(self)

		self.asset_cycle_fact.fill(self.asset_activity_fact) rescue (
			self.asset_cycle_fact = AssetCycleFact.create_by_asset(self)
			self.asset_cycle_fact.fill(self.asset_activity_fact)
		)
		self.asset_activity_fact.asset_cycle_fact_id = self.asset_cycle_fact._id
		self.asset_activity_fact.save!

#		self.add_to_invoice(options)
	end

	def move options
		# Options: time, location, correction
		self.handle_code = 5
		self.last_action_time = options[:time]
		self.location_id = options[:location_id]

		self.asset_activity_fact = AssetActivityFact.create_from_asset(self)
		self.asset_cycle_fact.move(self.asset_activity_fact) rescue (
			self.asset_cycle_fact = AssetCycleFact.create_by_asset(self)
			self.asset_cycle_fact.move(self.asset_activity_fact)
		)
		self.asset_activity_fact.asset_cycle_fact_id = self.asset_cycle_fact._id
		self.asset_activity_fact.save!

#		self.add_to_invoice(options)
	end


	def rfnet options
		# Options: time, location, correction
		if self.location_network != Location.find(options[:location_id]).network
			self.handle_code = 5	# Records as a move
			self.last_action_time = options[:time]
			self.location_id = options[:location_id]
			
			self.asset_activity_fact = AssetActivityFact.create_from_asset(self)
			self.asset_cycle_fact.move(self.asset_activity_fact) rescue (
				self.asset_cycle_fact = AssetCycleFact.create_by_asset(self)
				self.asset_cycle_fact.move(self.asset_activity_fact)
			)
			self.asset_activity_fact.asset_cycle_fact_id = self.asset_cycle_fact._id
			self.asset_activity_fact.save!

			print "RFNet Catch \n"
		end
	end	

	def audit options
		# HC = 7
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

	before_save :sync_descriptions	
	def sync_descriptions
		self.sku = Sku.find_or_create_by(entity: self.product.entity, primary_asset_type: self.asset_type, product: self.product)
		self.invoice_number = self.invoice.number rescue nil
		
		self.location_network = self.location.network		
#		self.fill_network = self.fill_location.network		
		self.product_entity = self.product.entity rescue nil

		# Check Descriptions
		self.network_description = self.network.description
		self.entity_description = self.entity.description	
		self.product_description = self.product.description
		
		self.product_entity_description = self.product_entity.description
		self.asset_type_description = self.asset_type.description	
		self.asset_status_description = self.get_asset_status_description		
		self.handle_code_description = self.get_handle_code_description
		self.location_description = self.location.description	
		self.location_network_description = self.location_network.description			

#		self.fill_network_description = self.fill_network.description
#		self.pickup_network_description = self.pickup_network.description
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

