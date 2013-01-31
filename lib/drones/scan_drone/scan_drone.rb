class ScanDrone
	require 's1'
#	require 'scan_object'	
	require 'scan_process'		
	require 'T0'	
	require 'T1'
	attr_accessor :processed_scans
	def initialize scans
		@processed_scans = Array.new
		scans.each do |scan|
			scan_obj = JSON.parse(scan)	

			scan = ScanProcess.new(scan_obj)
			@processed_scans.push(scan.scan_snap_shot)

#			self.process self.parse scan_obj
		end
	end	
=begin
	def process parsed_scan
	# *********************
	# GET EXISTING OBJECTS
	# *********************
		# User
		user = User.where(:email => parsed_scan.email).first		
		# Authorize User User
			#user = warden.authenticate(:scope => :user)		
		
		# Asset -- Auto Add if doesn't exist
		default_asset_state = AssetState.where(:description => 'Empty').first		

		asset = Asset.where(:network_id => parsed_scan.network._id, :tag_value => parsed_scan.value).first || Asset.new(:network_id => parsed_scan.network._id, :location_network => parsed_scan.location.network, :asset_state => default_asset_state, :tag_value => parsed_scan.value, :tag_key => parsed_scan.key, :entity_id => parsed_scan.network.entity._id)
		start_location_network_id = asset.location_network._id
		
		if asset.location_id == parsed_scan.location._id && asset.handle_code_id == HandleCode.where(:code => parsed_scan.handle_code.to_i).first.id && asset.updated_at.to_i > (Time.new.to_i - 86400)
			correction = true	
		end

	# *************
	# Processing
	# *************
		
		if !parsed_scan.asset_type.nil?
			asset.asset_type_id = parsed_scan.asset_type			
		end
		if parsed_scan.handle_code.to_i == 1 # Delivery
			asset.asset_state = AssetState.where(:description => 'Market').first
			asset.location_id = parsed_scan.location._id
			asset.location_network = Location.where(:id => asset.location_id).first.network
			asset.user_id = user.id
			asset.handle_code_id = HandleCode.where(:code => parsed_scan.handle_code.to_i).first.id
			asset.updated_at = parsed_scan.time.to_i

			#NEED TO ADD ACTION LOG ENTRY 			

		elsif parsed_scan.handle_code.to_i == 2	# Pickup	
			asset.asset_state = AssetState.where(:description => 'Empty').first
			asset.location_id = parsed_scan.location._id
			asset.location_network = Location.where(:id => asset.location_id).first.network
			asset.user_id = user.id
			asset.handle_code_id = HandleCode.where(:code => parsed_scan.handle_code.to_i).first.id
			asset.updated_at = parsed_scan.time.to_i
#			asset.product = nil
		elsif parsed_scan.handle_code.to_i == 3 # Add
			asset.location_id = parsed_scan.location._id
			asset.location_network = Location.where(:id => asset.location_id).first.network			
			asset.user_id = user.id
			asset.handle_code_id = HandleCode.where(:code => parsed_scan.handle_code.to_i).first.id
			asset.updated_at = parsed_scan.time.to_i


		elsif parsed_scan.handle_code.to_i == 4 # Fill
			asset.location_id = parsed_scan.location._id
			asset.location_network = Location.where(:id => asset.location_id).first.network			
			asset.user_id = user.id
			asset.handle_code_id = HandleCode.where(:code => parsed_scan.handle_code.to_i).first.id
			asset.updated_at = parsed_scan.time.to_i

			# NEED TO ADD ACTION ENTRY
			if asset.fill_time.nil?
				asset.fill_time =  0 #'1970-01-01 00:00:00 GMT'	
			end
			if asset.fill_time.to_i < (Time.new.to_i - 86400)
				# IF Last fill was not within 24 hours, fill as normal
				asset.product_id = parsed_scan.product
				asset.asset_state = AssetState.where(:description => 'Full').first
				asset.fill_count = asset.fill_count.to_i + 1
				asset.fill_time = Time.new
				puts 'Standard Fill Occured'
			elsif asset.fill_time.to_i > (Time.new.to_i - 86400)
				# IF Last fill was within 24 hours, update product & state
				asset.product_id = parsed_scan.product
				asset.asset_state = AssetState.where(:description => 'Full').first
				asset.fill_time = Time.new
				puts 'Fill Correction'
			end
		elsif parsed_scan.handle_code.to_i == 5 # Move
			asset.location_id = parsed_scan.location._id
			asset.location_network = Location.where(:id => asset.location_id).first.network			
			asset.user_id = user.id
			asset.handle_code_id = HandleCode.where(:code => parsed_scan.handle_code.to_i).first.id
			asset.updated_at = parsed_scan.time.to_i

			# NEED TO ADD ACTION ENTRY			
		elsif parsed_scan.handle_code.to_i == 6 # RF NET
			location = Location.where(:id => parsed_scan.location._id).first			
			if asset.location.network._id != location.network._id
				asset.location_id = parsed_scan.location._id
				asset.location_network = Location.where(:id => asset.location_id).first.network				
				asset.user_id = user.id
				asset.handle_code_id = HandleCode.where(:code => 5).first.id
				asset.updated_at = parsed_scan.time.to_i
			end
		end	
		if asset.tag_key.to_s == parsed_scan.key.to_s
			asset_snap_shot = {	:Network => asset.network.description,
								:Fill => asset.fill_count,
								:Value => asset.tag_value, 
								:Location => asset.location.description,
								:Brewery => asset.product.entity.description,
								:Product => asset.product.description,
								:Size => asset.asset_type.description,
								:Action => asset.handle_code.description,
								:State => asset.asset_state,
								:Time => asset.updated_at
						}
			@processed_scans.push asset_snap_shot
			
		else
			# ERROR ALERT KEY MIS MATCH
		end

#########################
# 	Metric Processing	#
#########################

		# Insert asset_activity_fact
		asset_activity_fact = AssetActivityFact.where(:asset => asset).order_by( [[:created_at, :asc ]]).last

		today = Date.today
		date = DateDimension.where(:day_of_year => today.yday, :year => today.year).first
		if correction == true && !asset_activity_fact.nil?
			# Find last entry for this asset & update		

			asset_activity_fact.asset = asset
			asset_activity_fact.entity = asset.entity
			asset_activity_fact.network = asset.network
			asset_activity_fact.date_dimension = DateDimension.where(:created_at.gte => (Date.today)).first

			asset_activity_fact.location = asset.location
			asset_activity_fact.location_network = asset.location_network
			asset_activity_fact.asset_state = asset.asset_state
			asset_activity_fact.asset_type = asset.asset_type
			asset_activity_fact.user = asset.user
			
			asset_activity_fact.product = asset.product
			asset_activity_fact.handle_code = asset.handle_code

			asset_activity_fact.fill_time = asset.fill_time
			asset_activity_fact.fill_count = asset.fill_count
			asset_activity_fact.updated_at = asset.updated_at										
			asset_activity_fact.date_dimension = date
		
			asset_activity_fact.save			
		else
			# Insert new activity
			
			AssetActivityFact.create(	
									:asset => asset,
									:entity => asset.entity,
									:network => asset.network,
									:date_dimension => date,

									:location => asset.location,
									:location_network => asset.location_network,
									:asset_state => asset.asset_state,
									:asset_type => asset.asset_type,									
									:user => asset.user,
									
									:product => asset.product,
									:handle_code => asset.handle_code,

									:fill_time => asset.fill_time,
									:fill_count => asset.fill_count									
								)
		end
		
		# Insert asset_network_movement_fact
		# If current network different then existing network, create network transaction
		if start_location_network_id != asset.location_network._id		
			# Create Asset Network Movement Fact
			AssetNetworkMovementFact.create(	:network_entry_date => asset.network_entry_time,
												:network_exit_date => Time.now,
												:asset => asset,
												:asset_type => asset.asset_type,
												:product => asset.product,
												:network => asset.network,
												:entity => asset.entity
											)

			# Set asset to new network
			asset.network_entry_time = Time.now
		end	
		
		if asset.handle_code.code != 7
			asset.save	
		end
	end
	def parse scan
		if scan['version']
			v = scan['version'].capitalize 
			parsed_scan = Object.const_get(v).new scan
			return parsed_scan
		else
			# execute default (S0)
			print 'No Version Found'
		end
	end	
=end
end
