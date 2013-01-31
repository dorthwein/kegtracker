=begin
class ScanObject
# **********************
# Attributes
# **********************
	# System/Data
	attr_accessor :scan	
	attr_accessor :asset	

	attr_accessor :correction
	attr_accessor :authenticated
	attr_accessor :reject

	attr_accessor :user
	attr_accessor :password
	attr_accessor :scan_date_dimension
	
	# Entry Network
	attr_accessor :entry_location_network_asset_state
	attr_accessor :entry_location_network_product
	attr_accessor :entry_location_network_time
	attr_accessor :entry_location_network_date
	
	# Exit Network
	attr_accessor :exit_location_network_asset_state
	attr_accessor :exit_location_network_product
	attr_accessor :exit_location_network_time
	attr_accessor :exit_location_network_date

	# New
	attr_accessor :new_asset_state
	attr_accessor :new_asset_type
	attr_accessor :new_location
	attr_accessor :new_location_network
	attr_accessor :new_updated_at
	attr_accessor :new_product
	attr_accessor :new_handle_code

	# Old
	attr_accessor :old_asset_state
	attr_accessor :old_asset_type
	attr_accessor :old_location
	attr_accessor :old_location_network_id
	attr_accessor :old_updated_at		
	attr_accessor :old_product	
	attr_accessor :old_handle_code	

	# Scan
	attr_accessor :scan_email
	attr_accessor :scan_password

	attr_accessor :scan_handle_code
	attr_accessor :scan_time	

	attr_accessor :scan_asset_type
	attr_accessor :scan_product
	attr_accessor :scan_location
	
	# Tag
	attr_accessor :tag_version
	attr_accessor :tag_value	
	attr_accessor :tag_network	
	attr_accessor :tag_key	

	# Alerts
	attr_accessor :scan_snap_shots

# **********************
# Methods
# **********************
	def initialize scan
		print "Processing Scan \n"
		@scan = scan
		parse_scan
		
		authenticate

		if @authenticated == true
			preprocess
			find_asset				
			
			process_general
			check_correction
			# Scan Processing
			case @scan_handle_code.to_i
			when 1 		# Delivery
				process_delivery
				print "Delivery \n"				
			when 2		# Pickup
				process_pickup
				print "Pickup \n"
			when 3		# Add
				process_add
				print "Add \n"
			when 4		# Fill
				process_fill
				print "Fill \n"
			when 5		# Move
				process_move
				print "Move \n"
			when 6		# RFNet
				process_rfnet
				print "RFNet \n"
			when 7		# Audit
				process_audit
				print "Audit \n"			
			else
				print "HC Error"
			end
			
			print "Scan Complete \n"			
			if @reject != true
				print "Not Rejected \n"
				create_asset_activity_fact				
				create_network_movement_fact				
			else
				print "Rejected \n"			
			end
			process_post_scan			
		end
	end	

	def authenticate
		@user = User.where(:email => @scan_email).first
		@authenticated = true
		print "Scan Authenticated \n"
	end
	
	def find_asset
		print "Finding asset..."
		default_asset_state = AssetState.where(:description => 'Empty').first			
		@asset = 	Asset.where(
						:netid => @tag_network.netid,
						:tag_value => @tag_value
						).first || 
					Asset.new(
						:network_id => @tag_network._id, 
						:location_network => @location.network, 
						:asset_state => default_asset_state, 
						:tag_value => @tag_value,
						:netid => @tag_network.netid,
						:tag_key => @tag_key, 
						:entity_id => @tag_network.entity._id
					)
		print "asset found \n"
	end	
		
	def check_correction
		print "Checking if correction \n"
		# Same Location & Same Action & Within 24 Hours
		if @asset.location == @new_location && @asset.handle_code.code.to_i == @scan_handle_code.to_i && @asset.last_action_time.to_i > (@scan_time.to_i - 86400)
			@correction = true
			print "Standard Correction \n"
		end

		# Same Location within 15 minutes but not a fill
		if @asset.location == @new_location && @scan_handle_code.to_i != 4 && @asset.last_action_time.to_i > (@scan_time.to_i - 900)
			@correction = true
			print "Same Location within 15 minutes \n"
		end
				
		# Fill action within last day
		if @scan_handle_code.to_i == 4 && @asset.fill_time.to_i > (@scan_time.to_i - 86400)
			@correction = true
			print "Fill Correction \n"
		end
	end
	
# ********************
# Scan Processing
# ********************			

	def preprocess
		# Before Find Asset
		@new_location = Location.find(@scan_location)
		@new_location_network = @new_location.network

		print @scan_time.to_s + "\n"		
		scan_date = Time.at(@scan_time.to_i).to_date	
		@scan_date_dimension = DateDimension.where(:day_of_year => scan_date.yday, :year => scan_date.year).first
			
		if @tag_network.nil?
			@tag_network = @new_location_network
		else
			@tag_network = Network.where(:netid => @tag_network).first		
		end
	end

	def process_general
	# After Find Asset
		if @asset.fill_time.nil?
			@asset.fill_time =  0 #'1970-01-01 00:00:00 GMT'
		end					
		if !@scan_asset_type.nil?
			@new_asset_type = AssetType.find(@scan_asset_type)
			@asset.asset_type = @new_asset_type
			@asset.save
		end
		
		@old_asset_state = @asset.asset_state
		@old_asset_type	= @asset.asset_type
		@old_location = @asset.location
		@old_location_network_id = @asset.location_network._id
		@old_updated_at	= @asset.last_action_time
		@old_product = @asset.product
		@old_handle_code = @asset.handle_code
	end
	
	def process_delivery
		@new_asset_state = AssetState.where(:description => 'Market').first
		@new_handle_code = HandleCode.where(:code => @scan_handle_code.to_i).first
		
		@asset.asset_state = @new_asset_state
		@asset.location = @new_location
		@asset.location_network = @new_location_network
		@asset.user = @user
		@asset.handle_code = @new_handle_code
		@asset.last_action_time = @scan_time	
		
		@asset.save
	end
	
	def process_pickup
		@new_asset_state = AssetState.where(:description => 'Empty').first
		@new_handle_code = HandleCode.where(:code => @scan_handle_code.to_i).first

		@asset.asset_state = @new_asset_state
		@asset.location = @new_location
		@asset.location_network = @new_location_network
		@asset.user = @user
		@asset.handle_code = @new_handle_code
		@asset.last_action_time = @scan_time
		
		@asset.save
	end
	
	def process_add
		@new_handle_code = HandleCode.where(:code => @scan_handle_code.to_i).first
		
		@asset.location = @new_location
		@asset.location_network = @new_location_network
		@asset.user = @user
		@asset.handle_code = @new_handle_code
		@asset.last_action_time = @scan_time

		@asset.save
	end
	
	def process_fill
		@new_handle_code = HandleCode.where(:code => @scan_handle_code.to_i).first
		@new_asset_state = AssetState.where(:description => 'Full').first
		@new_product = Product.find(@scan_product)

		# CHECK FOR CORRECTION	
		if @correction == true
			@asset.asset_state = @new_asset_state
			@asset.location = @new_location
			@asset.location_network = @new_location_network
			@asset.fill_network = @new_location_network
			
			@asset.user = @user
			@asset.handle_code = @new_handle_code
			@asset.last_action_time = @scan_time

			@asset.product = @new_product
			@asset.fill_time = @scan_time
		else
			@asset.asset_state = @new_asset_state
			@asset.location = @new_location
			@asset.location_network = @new_location_network
			@asset.fill_network = @new_location_network
						
			@asset.user = @user
			@asset.handle_code = @new_handle_code
			@asset.last_action_time = @scan_time
		
			@asset.product = @new_product
			@asset.fill_time = @scan_time		
			@asset.fill_count = @asset.fill_count.to_i + 1						
		end
		@asset.save					
	end
	
	def process_move
		@new_handle_code = HandleCode.where(:code => @scan_handle_code.to_i).first
		
		@asset.asset_state = @new_asset_state
		@asset.location = @new_location
		@asset.location_network = @new_location_network
		@asset.user = @user
		@asset.handle_code = @new_handle_code
		@asset.last_action_time = @scan_time				
		
		@asset.save		
	end
	
	def process_rfnet
		if @asset.location.network != @new_location_network # && @asset.location.partner_entity == 0 
			@new_handle_code = HandleCode.where(:code => 5).first
			@asset.location = @new_location
			@asset.location_network = @new_location_network
			@asset.user = @user
			@asset.handle_code = @new_handle_code
			@asset.last_action_time = @scan_time			
			@asset.save
		else
			@reject = true
		end		
	end
	
	def process_audit
		
	end	
# ********************
# Parse Tags
# ********************	
	def parse_scan


	 Sets:
	 	@email, @password	
	 	@handle_code, @time, @location, @asset_type, @product
		@tag_version, @tag_value, @tag_network, @tag_key 			


	# User/Password
		@scan_email = @scan['user']['N']
		@scan_password = @scan['user']['P']
	
	# Processing
		@scan_handle_code = @scan['processing']['HC']
		@scan_time = @scan['processing']['T']

		@scan['processing']['P'] ? @scan_product = @scan['processing']['P'] : nil
		@scan['processing']['AT'] ? @scan_asset_type = @scan['processing']['AT'] : nil
				

	# Location
		@scan_location = @scan['location']

	# TAG
		if !@scan['tag'][0].nil? 								# If array [0] nil, then must be hash
			if @scan['tag'].kind_of?(Array)						# If array, assume tag version in [0]
				@tag_version = @scan['tag'][0].capitalize	

				if @tag_version == 'T1'
					@tag_value 		= @scan['tag'][1]
					@tag_network 	= @scan['tag'][2]
					@tag_key 		= @scan['tag'][3]
				end						
			end
		else
		# Default to T0			
			@tag_version = 'T0'	# scan['tag'][0].capitalize
			@tag_value = @scan['tag']['V']
			
		# Check for Network
			if !@scan['tag']['N'].nil?	
				@tag_network = @scan['tag']['N']
			end
			
		# Default - Check for Key
			if @scan['tag']['K'].nil?
				@tag_key = 0
			else
				@tag_key = @scan['tag']['K']
			end
		end	
	end

	def parse_tag_version_0
		# NOT USED - TAG PARSE INCLUDED IN SCAN PARSE UNTIL MULTIPLE SCAN FORMATS USED
	end

	def parse_tag_version_1
		# NOT USED - TAG PARSE INCLUDED IN SCAN PARSE UNTIL MULTIPLE SCAN FORMATS USED
	end

	def process_post_scan
		@asset.last_action_time = @scan_time		
		if @old_location_network_id != @asset.location_network._id && @asset.location.network.production == 1 && @asset.handle_code.code != 4
			@asset.product = nil		
		end
		@asset.save		
	end

# ********************
# Alerts
# ********************
	def scan_snap_shot
		@scan_snap_shot = {
			:Network => @asset.network.description,
			:Fill => @asset.fill_count,
			:Value => @asset.tag_value, 
			:Location => @asset.location.description,
			:Brewery => @asset.product.entity.description,
			:Product => @asset.product.description,
			:Size => @asset.asset_type.description,
			:Action => @asset.handle_code.description,
			:State => @asset.asset_state,
			:Time => @asset.last_action_time
		}
	end
	
# ********************
# Create Reports
# ********************
	def create_asset_activity_fact
		asset_activity_fact = AssetActivityFact.where(:asset => @asset).order_by( [[:fact_time, :desc ]]).last
		if correction == true && !asset_activity_fact.nil?
			# Correct Last Activity Fact				
			print "Fact Change \n \n"	

		# Fields	
			asset_activity_fact.fill_time = @asset.fill_time
			asset_activity_fact.fill_count = @asset.fill_count

		# Relations
			asset_activity_fact.asset = @asset
		
		# Networks
			asset_activity_fact.network = @asset.network
			asset_activity_fact.location_network = @asset.location_network			
	
		# Entity
			asset_activity_fact.entity = @asset.entity

		# Asset Details
			asset_activity_fact.asset_state = @asset.asset_state
			asset_activity_fact.asset_type = @asset.asset_type
			asset_activity_fact.product = @asset.product			

		# Location
			asset_activity_fact.location = @asset.location
		
		# Activity
			asset_activity_fact.user = @asset.user
			asset_activity_fact.handle_code = @asset.handle_code

		# Date Dimension
			asset_activity_fact.fact_time = @asset.last_action_time



		
			asset_activity_fact.save			
		else 
			print "New Activity Fact Created \n \n"
			# Create New Activity Fact
			AssetActivityFact.create(	
									:asset => @asset,
									:entity => @asset.entity,
									:network => @asset.network,

									:location => @asset.location,
									:location_network => @asset.location_network,
									:asset_state => @asset.asset_state,
									:asset_type => @asset.asset_type,									
									:user => @asset.user,
									
									:product => @asset.product,
									:handle_code => @asset.handle_code,

									:fill_time => @asset.fill_time,
									:fill_count => @asset.fill_count									
								)
		end
	end
	
	def create_network_movement_fact
		print "Network Movement Fact \n"
		print " --- "
		print @scan_date_dimension
		print "\n"
		if @old_location_network_id != @asset.location_network._id
			print "Creating Network Movement Fact \n"
			# Create Asset Network Movement Fact
			if @asset.asset_network_movement_fact.nil?				
				# If Nil Just create
				@new_asset_network_movement_fact = AssetNetworkMovementFact.create(
													:entry_location_network_date => @scan_date_dimension,
													:entry_location_network => @new_location_network,													
													:entry_location_network_asset_state => @new_asset_state,												
													:entry_location_network_time => @scan_time,
													
													:asset => @asset,
													:asset_type => @asset.asset_type,
													:product => @asset.product,
													:network => @asset.network,
													:entity => @asset.entity
												)
				@asset.asset_network_movement_fact = @new_asset_network_movement_fact
				@asset.save
			else 
				# Finalize Exit
				@old_asset_network_movement_fact = @asset.asset_network_movement_fact				
				@old_asset_network_movement_fact.exit_location_network = @new_location_network
				@old_asset_network_movement_fact.exit_location_network_date = @scan_date_dimension
				@old_asset_network_movement_fact.exit_location_network_time = @scan_time
				@old_asset_network_movement_fact.exit_location_network_asset_state = @new_asset_state					

				@old_asset_network_movement_fact.save
				# Create New
				@new_asset_network_movement_fact = AssetNetworkMovementFact.create(
													:entry_location_network_date => @scan_date_dimension,
													:entry_location_network => @new_location_network,													
													:entry_location_network_asset_state => @new_asset_state,												
													:entry_location_network_time => @scan_time,
												
													:asset => @asset,
													:asset_type => @asset.asset_type,
													:product => @asset.product,
													:network => @asset.network,
													:entity => @asset.entity
												)

				@asset.asset_network_movement_fact = @new_asset_network_movement_fact
				@asset.save				
			end	

			# Set asset to new network
		end	
	end		
end

=end