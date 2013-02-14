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
	belongs_to :invoice
	belongs_to :invoice_detail

	field :invoice_number, type: String

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


	# Set before all actions to detect if the asset should have "Smart Actions" applied to it.
=begin
	def smart_network_processing options
		to_location = Location.find(options[:to_location])
		to_network = to_location.network

		print to_network.description + " -- " + to_location.description + " \n"
		if self.location_network_id != to_network._id		
			print "Smart Network Processing \n"
		# Effects at From Network
		### OUTBOUND ####
		# Asset Leaving a brewery
			if self.location_network.nil?
				self.location_network = to_network
			end
			if self.location.nil?
				self.location = to_location
			end
			
			if self.location_network.network_type == 1 && self.asset_status != 1
				# Fill Asset at Outbound Location
				opt = {
						:product => self.location_network.smart_mode_product,
						:location_id => self.location_network.smart_mode_out_location._id,
						:correction => options[:correction],
						:time => options[:time]
					}
				self.fill(opt)			
			end

			# Asset leaving a distributor/market pickup at Outbound Location
			if (self.location_network.network_type == 2 || self.location_network.network_type == 3) && to_network.network_type == 1 && self.asset_status != 0
				opt = {
						:location_id => self.location_network.smart_mode_out_location._id,
						:correction => options[:correction],
						:time => options[:time]
					}
				self.pickup(opt)

			end

			### INBOUND ###			
			# Asset Arriving at Production Facility - Empty asset, purge other entity product
			if to_network.network_type == 1
				# Needs to be changed to check for Authorized products
				if to_network.entity != self.product.entity
					self.product = nil
				end
				opt = {
						:location_id => self.location_network.smart_mode_out_location._id,
						:correction => options[:correction],
						:time => options[:time]
					}
				self.pickup(opt)
			end
		end
		self.save
	end
=end	
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
		
			self.invoice_detail = invoice.add_invoice_asset_detail({:asset => self, :asset_activity_fact => self.asset_activity_fact})
		end
	end

	def deliver options
		# Options: time, location, correction, invoice
		self.handle_code = 1
		self.asset_status = 2
		print options[:time].to_s + "<--- \n" 
		
		self.last_action_time = options[:time]		
		self.location_id = options[:location_id]
		
		self.delivery_time = options[:time]
		self.delivery_location_id = options[:location_id]				
		self.create_asset_activity_fact

		self.add_to_invoice(options)

	end	

	def pickup options
		# Options: time, location, correction, invoice
		self.handle_code = 2
		self.asset_status = 0		
		self.last_action_time = options[:time]
		
		self.location_id = options[:location_id]
		
		self.pickup_time = options[:time]
		self.pickup_location_id = options[:location_id]
		self.create_asset_activity_fact

		self.add_to_invoice(options)
	end

	def add	options
		# Options: time, location, correction		
		self.handle_code = 3
		self.asset_status = 0		
		self.last_action_time = options[:time]

		self.location_id = options[:location_id]

		self.create_asset_activity_fact
		self.add_to_invoice(options)
	end
	
	def fill options
		# Options: time, location_id, product_id, correction
		self.handle_code = 4		
		self.asset_status = 1

		self.last_action_time = options[:time]				
		
		self.location_id = options[:location_id]

		self.product_id = options[:product_id]
		self.fill_time = options[:time]
		self.fill_location_id = options[:location_id]
		

		self.fill_count = self.fill_count.to_i + 1
		self.create_asset_activity_fact
		self.add_to_invoice(options)
	end

	def move options
		# Options: time, location, correction
		self.handle_code = 5
		self.last_action_time = options[:time]
		self.location_id = options[:location_id]

		self.create_asset_activity_fact
		self.add_to_invoice(options)
	end

	def rfnet options
		# Options: time, location, correction
		if self.location_network != Location.find(options[:location_id]).network
			self.handle_code = 5	# Records as a move
			self.last_action_time = options[:time]
			self.location_id = options[:location_id]

			self.create_asset_activity_fact
			self.add_to_invoice(options)
		end
	end	

	def audit options
		# HC = 7
	end

	def create_asset_activity_fact options = {}
		# Options: correction
		asset_activity_fact_details = {
									:asset_id => self._id,
									:asset_status => self.asset_status,
									:asset_type_id => self.asset_type_id,																		
									:entity_id => self.entity_id,

									:product => self.product,
									:handle_code => self.handle_code.to_i,
									
									:fact_time => self.last_action_time,
									:fill_count => self.fill_count.to_i,
									
									:location_id => self.location_id,
									:location_network_id => self.location_network_id,

									# :network => self.network, Possible Depricated
#									:fill_network => self.fill_network,
									:user => self.user,
#									:fill_time => asset.fill_time,								
								}
#		fact = AssetActivityFact.where(:_id => self.asset_activity_fact._id).first
#		if options[:correction] == 1 && !fact.nil?		
#			fact.update_attributes(asset_activity_fact_details)
#			print " \n \n"	
#			print fact.to_json
#			print " \n \n"	
#			print "Fact Change \n \n"	
#		else	
			asset_activity_fact = AssetActivityFact.create(asset_activity_fact_details)
			self.asset_activity_fact = asset_activity_fact
			self.save			
#			print "  New Fact \n \n"	
#		end		
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
=begin
	def self.process_scans options
		# expects HASH with key :scans => [Array of Scans]
		scans = options[:scans]
		scans.each do |scan|
			scan = JSON.parse(scan)	

		############################
		####### Scan Parsing #######		
			scan_params = {}

			scan_params[:email] = scan['user']['N']
			scan_params[:password] = scan['user']['P']
			scan_params[:handle_code] = scan['processing']['HC'].to_i 
			scan_params[:correction] = scan['processing']['correction'].to_i
			scan_params[:auto_mode] = scan['processing']['auto_mode'].to_i	
			scan_params[:time] = Time.at(scan['processing']['T'].to_i)

			scan['processing']['P'] ? scan_params[:product_id] = scan['processing']['P'] : nil
			scan['processing']['AT'] ? scan_params[:asset_type_id] = scan['processing']['AT'] : nil

			scan_params[:location_id] = scan['location']
			scan_params[:tag] = {}
			# TAG
			if !scan['tag'][0].nil? 								# If array [0] nil, then must be hash
				if scan['tag'].kind_of?(Array)						# If array, assume tag version in [0]
					scan_params[:tag][:version] = scan['tag'][0].capitalize	

					if scan_params[:tag][:version] == 'T1'
						scan_params[:tag][:value] = scan['tag'][1]
						scan_params[:tag][:netid] = scan['tag'][2]
						scan_params[:tag][:key] = scan['tag'][3]
					end						
				end
			else
			# Default to T0			
				scan_params[:tag][:version] = 'T0'	# scan['tag'][0].capitalize
				scan_params[:tag][:value] = scan['tag']['V']
				
			# Check for Network
				if !scan['tag']['N'].nil?	
					scan_params[:tag][:netid] = scan['tag']['N']
				end
				
			# Default - Check for Key
				if scan['tag']['K'].nil?
					scan_params[:tag][:key] = 0
				else
					scan_params[:tag][:key] = scan['tag']['K']
				end
			end



		##############################
		####### Pre Processing #######			
			user = User.where(:email => scan_params[:email]).first			
			if scan_params[:tag][:netid].nil?			
				tag_network = user.entity.networks.first
			else
				tag_network = Network.where(:netid => scan_params[:tag][:netid]).first		
			end

			asset = Asset.where(
							:netid => tag_network.netid,
							:tag_value => scan_params[:tag][:value]
							).first || 
						Asset.new(
							:network_id => tag_network._id, 
							:location_id => scan_params[:location_id],
#							:location_network => location.network, 
							:asset_status => 0, 
							:tag_value => scan_params[:tag][:value],
							:netid => tag_network.netid,
							:tag_key => scan_params[:tag][:key],
							:entity_id => tag_network.entity._id
						)

			asset.user = User.where(:email => scan_params[:email]).first		
			
			if !scan_params[:asset_type_id].nil?
				asset.asset_type = AssetType.find(scan_params[:asset_type_id])
			end

		################################
		####### Check Correction #######						
			if asset.location_id == scan_params[:location_id] && asset.handle_code.to_i == scan_params[:handle_code] && asset.last_action_time.to_i > (scan_params[:time].to_i - 86400)
				print "Standard Correction \n"
				scan_params[:correction] = 1
			end

			# Same Location within 15 minutes but not a fill
			if asset.location == scan_params[:location_id] && scan_params[:handle_code].to_i != 4 && asset.last_action_time.to_i > (scan_params[:time].to_i - 900)			
				print "Same Location within 15 minutes \n"
				scan_params[:correction] = 1	
			end
					
			# Fill action within last day
			if scan_params[:handle_code].to_i == 4 && asset.fill_time.to_i > (scan_params[:time].to_i - 86400)
				print "Fill Correction \n"
				scan_params[:correction] = 1			
			end
			asset.save!

		################################
		####### Asset Processing #######				
			asset.smart_network_processing({:time => scan_params[:time], :to_location => scan_params[:location_id], :correction => scan_params[:correction]})

			case scan_params[:handle_code].to_i
			when 1 		# Delivery
				asset.deliver(options)				
				print "Delivery \n"				
			
			when 2		# Pickup
				asset.pickup(options)				
				print "Pickup \n"
			
			when 3		# Add
				asset.add(options)				
				print "Add \n"
			
			when 4		# Fill
				asset.fill(options)				
				print "Fill \n"
			
			when 5		# Move
				asset.move(options)				
				print "Move \n"
			
			when 6		# RFNet
				asset.rfnet(options)				
				print "RFNet \n"			
			when 7		# Audit
				asset.process_audit
				print "Audit \n"			
			else
				print "HC Error \n"
			end
			asset.save	

			@scan_snap_shot = {
				:Network => asset.network_description,
				:Fill => asset.fill_count,
				:Value => asset.tag_value, 
				:Location => asset.location_description,
				:Brewery => asset.product_entity_description,
				:Product => asset.product_description,
				:Size => asset.asset_type_description,
				:Action => asset.handle_code_description,
				:State => asset.asset_status_description,
				:Time => asset.last_action_time
			}
#			asset.save!
			
#			scan = ScanProcess.new(scan_obj)		
#			scan_snap_shot.to_json
		end
		@scan_snap_shot 
		#return scan_snap_shot
	end
=end

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
		self.invoice = self.invoice_detail.invoice rescue nil
		self.invoice_number = self.invoice.number rescue nil
		
		self.location_network = self.location.network		
		self.fill_network = self.fill_location.network		

		# Check Descriptions
		self.network_description = self.network.description
		self.entity_description = self.entity.description	
		self.product_description = self.product.description
		
		self.product_entity_description = self.product.nil? ? ' ' : self.product.entity.description	

		self.asset_type_description = self.asset_type.description	
		self.asset_status_description = self.get_asset_status_description		
		self.handle_code_description = self.get_handle_code_description

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



