
class ScanProcess
	attr_accessor :scan_snap_shots
	def initialize scan
		print "Processing Scan \n"
		@scan = scan

		parse_scan

		if authenticate
			preprocess	
			find_asset				
			
			process_general
			check_correction
			# Scan Processing

			# Check for smart networks
			@asset.smart_network_processing({:time => @scan_time, :to_location => @scan_location, :correction => check_correction})
			case @scan_handle_code.to_i
			when 1 		# Delivery
				@asset.deliver({:time => @scan_time, :location => @scan_location, :correction => check_correction})				
				print "Delivery \n"				
			
			when 2		# Pickup
				@asset.pickup({:time => @scan_time, :location => @scan_location, :correction => check_correction})
				print "Pickup \n"
			
			when 3		# Add
				@asset.add({:time => @scan_time, :location => @scan_location, :correction => check_correction})
				print "Add \n"
			
			when 4		# Fill
				@asset.fill({:time => @scan_time, :location => @scan_location, :product => @scan_product, :correction => check_correction})
				print "Fill \n"
			
			when 5		# Move
				@asset.move({:time => @scan_time, :location => @scan_location, :correction => check_correction})
				print "Move \n"
			
			when 6		# RFNet
				@asset.rfnet({:time => @scan_time, :location => @scan_location, :correction => check_correction})
				print "RFNet \n"			
			when 7		# Audit
				process_audit
				print "Audit \n"			
			else
				print "HC Error \n"
			end
			@asset.save
			print "Scan Complete \n"			
		end
	end	

	def authenticate
		@user = User.where(:email => @scan_email).first
		return true
	end
	
	def find_asset
		print "Finding asset..."
		@asset = 	Asset.where(
						:netid => @tag_network.netid,
						:tag_value => @tag_value
						).first || 
					Asset.new(
						:network_id => @tag_network._id, 
						:location_network => @location.network, 
						:asset_status => 0, 
						:tag_value => @tag_value,
						:netid => @tag_network.netid,
						:tag_key => @tag_key, 
						:entity_id => @tag_network.entity._id
					)
		print "asset found \n"
	end	
		
	def check_correction
		# Same Location & Same Action & Within 24 Hours
		if @asset.location_id == @scan_location && @asset.handle_code.to_i == @scan_handle_code.to_i && @asset.last_action_time.to_i > (@scan_time.to_i - 86400)
			print "Standard Correction \n"
			return true
		end

		# Same Location within 15 minutes but not a fill
		if @asset.location == @new_location && @scan_handle_code.to_i != 4 && @asset.last_action_time.to_i > (@scan_time.to_i - 900)			
			print "Same Location within 15 minutes \n"
			return true			
		end
				
		# Fill action within last day
		if @scan_handle_code.to_i == 4 && @asset.fill_time.to_i > (@scan_time.to_i - 86400)			
			print "Fill Correction \n"
			return true			
		end
		if @scan_correction == 1
			return true
		end
		return false			
	end
	
# ********************
# Scan Processing
# ********************			
	def preprocess
		if @tag_network_netid.nil?			
			@tag_network = @user.entity.networks.first
		else
			@tag_network = Network.where(:netid => @tag_network_netid).first		
		end
		print "\nNetid: " + @tag_network.netid.to_s + " - " + @tag_network.description + " \n"		
	end
	def process_general
	# After Find Asset
		@asset.user = User.where(:email => @scan_email).first
		if !@scan_asset_type.nil?		
			@asset.asset_type = AssetType.find(@scan_asset_type)
		end
		@asset.save!
	end
	def parse_scan	
	# User/Password
		@scan_email = @scan['user']['N']
		@scan_password = @scan['user']['P']
	
	# Processing
		@scan_handle_code = @scan['processing']['HC']
		@scan_correction = @scan['processing']['correction'].to_i
		@scan_time = Time.at(@scan['processing']['T'].to_i)

		@scan['processing']['P'] ? @scan_product = @scan['processing']['P'] : nil
		@scan['processing']['AT'] ? @scan_asset_type = @scan['processing']['AT'] : nil

	# Location
		@scan_location = @scan['location']

	# TAG
		if !@scan['tag'][0].nil? 								# If array [0] nil, then must be hash
			if @scan['tag'].kind_of?(Array)						# If array, assume tag version in [0]
				@tag_version = @scan['tag'][0].capitalize	

				if @tag_version == 'T1'
					@tag_value = @scan['tag'][1]
					@tag_network_netid = @scan['tag'][2]
					@tag_key = @scan['tag'][3]
				end						
			end
		else
		# Default to T0			
			@tag_version = 'T0'	# scan['tag'][0].capitalize
			@tag_value = @scan['tag']['V']
			
		# Check for Network
			if !@scan['tag']['N'].nil?	
				@tag_network_netid = @scan['tag']['N']
			end
			
		# Default - Check for Key
			if @scan['tag']['K'].nil?
				@tag_key = 0
			else
				@tag_key = @scan['tag']['K']
			end
		end	
		print "\nTag Version: " + @tag_version + "\n"
	end
# ********************
# Alerts
# ********************
	def scan_snap_shot
		@scan_snap_shot = {
			:Network => @asset.network_description,
			:Fill => @asset.fill_count,
			:Value => @asset.tag_value, 
			:Location => @asset.location_description,
			:Brewery => @asset.product_entity_description,
			:Product => @asset.product_description,
			:Size => @asset.asset_type_description,
			:Action => @asset.handle_code_description,
			:State => @asset.asset_status_description,
			:Time => @asset.last_action_time
		}
	end
end
