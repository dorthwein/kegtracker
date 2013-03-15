class Scanner	
	def self.process_scans options
		# expects HASH with key :scans => [Array of Scans]
		scans = options[:scans]
		processed_scans = []

		scans.each do |scan|
			obj = Scanner.parse_scan(scan)	# Parse Scan
			obj = Scanner.find_asset(obj)	# Find/Create Asset						

			obj = Scanner.check_correction(obj)

			if obj[:correction] == 1
				obj = Scanner.rollback_scan(obj)
			end

			obj = Scanner.preprocess_asset(obj)
			
			if obj[:auto_mode] == 1 && obj[:from_network] != obj[:to_network]
				obj = Scanner.auto_mode_process(obj)
			end

			obj = Scanner.normal_process(obj)
			
			if obj[:invoice_id] != '' && !obj[:invoice_id].nil?
				Scanner.invoice_process(obj)
			end

			obj[:asset].save!
			processed_scans.push(Scanner.snap_shot(obj))
		end
		return processed_scans
	end	

	# Rollback logic needs to be moved to various models
	def self.rollback_scan obj
		# Check for invoice - roll back invoice		
		obj[:asset].asset_activity_fact.destroy rescue nil
		return obj
	end

	def self.snap_shot obj
		scan_snap_shot = {
			:Network => obj[:asset].network_description,
			:Fill => obj[:asset].fill_count,
			:Value => obj[:asset].tag_value, 
			:Location => obj[:asset].location_description,
			:Brewery => obj[:asset].product_entity_description,
			:Product => obj[:asset].product_description,
			:Size => obj[:asset].asset_type_description,
			:Action => obj[:asset].handle_code_description,
			:State => obj[:asset].asset_status_description,
			:Time => obj[:asset].last_action_time
		}		
		obj[:snap_shot] = scan_snap_shot
		return obj 
	end

	# Logic moved to asset
	def self.auto_mode_process obj		
		obj = Scanner.auto_mode_from_brewery(obj)
		obj = Scanner.auto_mode_to_brewery(obj)
		obj = Scanner.auto_mode_to_distributor(obj)
		obj = Scanner.auto_mode_to_market(obj)
		obj = Scanner.auto_mode_from_market(obj)
		obj[:asset].save!
		return obj
	end

	def self.auto_mode_from_brewery obj
		# Ensure Filled  brewery location
		if obj[:from_network].network_type == 1
			if obj[:asset].asset_status != 1
				# If not full - fill				
				obj[:asset].fill({ 	
					:time => obj[:time] - 1,
					:location_id => obj[:from_network].smart_mode_out_location._id,
					:product_id => obj[:from_network].smart_mode_product._id,
					:correction => obj[:correction]
				})
			end
		end
		return obj
	end

	def self.auto_mode_to_brewery obj
		if obj[:to_network].network_type == 1 && obj[:handle_code] != 4
			obj[:handle_code] = 2
			if obj[:asset].product.entity != obj[:to_network].entity
				obj[:asset].product = nil
			end
=begin
			if obj[:asset].asset_status != 0
				# If not empty - pickup				
				obj[:asset].pickup({ 	
					:time => obj[:time] - 1,
					:location_id => obj[:from_network].smart_mode_out_location._id,
					:correction => obj[:correction]
				})
			end
=end
		end
		return obj
	end	

	def self.auto_mode_to_distributor obj
		if obj[:to_network].network_type == 2 && obj[:to_network].auto_mode == 1
			# If asset full, change to delivery
			if obj[:asset].asset_status == 1
				obj[:handle_code] = 1
			# If asset in market, change to pickup
			elsif obj[:asset].asset_status == 2
				obj[:handle_code] = 2
			end
		end
		return obj
	end
		

	def self.auto_mode_to_market obj
		# Change HC to delivery
		if obj[:to_network].network_type == 3 # && obj[:to_network].auto_mode == 1		
			obj[:handle_code] = 1
		end
		return obj		
	end

	def self.auto_mode_from_market obj
		if obj[:from_network].network_type == 3 # && obj[:to_network].auto_mode == 1		
			obj[:handle_code] = 2
		end
		return obj
	end

	def self.normal_process obj
		case obj[:handle_code].to_i
		when 1 		# Delivery
			obj[:asset].deliver(obj)				
			print "Delivery \n"				
		
		when 2		# Pickup
			obj[:asset].pickup(obj)				
			print "Pickup \n"
		
#		when 3		# Add
#			obj[:asset].add(obj)				
#			print "Add \n"
		
		when 4		# Fill
			obj[:asset].fill(obj)				
			print "Fill \n"
		
		when 5		# Move
			obj[:asset].move(obj)				
			print "Move \n"

		when 6		# RFNet
			obj[:asset].rfnet(obj)				
#			if obj[:asset].location_network_id.to_s != Location.find(obj[:location_id]).network_id.to_s
#				obj[:asset].move(obj)				
#
#				print "RFNet \n" + obj[:asset].location_network.description.to_s
#			end
		when 7		# Audit
			obj[:asset].process_audit
			print "Audit \n"			
		else
			print "HC Error \n"
		end
		obj[:asset].save!
		return obj
	end

	def self.invoice_process obj			
		invoice = Invoice.find(obj[:invoice_id])
		invoice.attach_asset(obj)
		#return obj
	end

	def self.check_correction obj
	################################
	####### Check Correction #######				
		if obj[:correction] == 1
			print "Correction Toggled On \n"
		end

		# Same Location within last day minutes but not a fill		
		if obj[:asset].location._id.to_s == obj[:location_id] && (obj[:handle_code].to_i != 4 || obj[:handle_code].to_i != obj[:asset].handle_code.to_i) && obj[:asset].last_action_time.to_i > (obj[:time].to_i - 86400)			
			print "Same Location within 15 minutes Correction \n"
			obj[:correction] = 1	
		end
		if obj[:handle_code].to_i == 6 
			obj[:correction] = 0
			print "RFNet - deffering to RF Logic \n"
		end	
		# Fill action within last day & asset current full
		if obj[:handle_code].to_i == 4 && obj[:asset].asset_status.to_i == 1 && obj[:asset].fill_time.to_i > (obj[:time].to_i - 86400)
			print "Fill Correction \n"
			obj[:correction] = 1			
		end
		return obj
	end

	def self.find_asset obj
		##############################
		####### Pre Processing #######			
		user = User.where(:email => obj[:email]).first				
		if obj[:tag][:netid].nil?			
			obj[:tag][:network] = user.entity.networks.first
		else
			obj[:tag][:network] = Network.where(:netid => obj[:tag][:netid]).first		
		end	

		obj[:asset] = Asset.where(netid: obj[:tag][:network].netid, tag_value: obj[:tag][:value]).first
		
		if obj[:asset].nil? 
			obj[:asset] = Asset.new(
				:location_id => obj[:location_id],				
				:network_id => obj[:tag][:network]._id, 
				:asset_status => 0, 
				:tag_value => obj[:tag][:value],
				:netid => obj[:tag][:network].netid,
				:tag_key => obj[:tag][:key], 
				:entity_id => obj[:tag][:network].entity._id
			)		
		end		
		obj[:asset].save!
		return obj
	end
	def self.preprocess_asset obj
		obj[:asset].user = User.where(:email => obj[:email]).first		

	# Asset Type Override				
		if !obj[:asset_type_id].nil?
			obj[:asset].asset_type = AssetType.find(obj[:asset_type_id])
			print obj[:asset].asset_type.to_json
		end

		obj[:to_network] = Location.find(obj[:location_id]).network
		obj[:from_network] = obj[:asset].location.network || obj[:to_network]
		obj[:asset].save!

		return obj
	end
	def self.parse_scan obj		
		scan = JSON.parse(obj)	
		scan_params = {}

		scan_params[:email] = scan['email']
		scan_params[:password] = scan['password']
		scan_params[:handle_code] = scan['handle_code'].to_i 
		scan_params[:correction] = scan['correction'].to_i
		scan_params[:auto_mode] = scan['auto_mode'].to_i	

		scan_params[:invoice_id] = scan['invoice_id']
		scan_params[:time] = Time.at(scan['time'].to_i)

		scan['product_id'] ? scan_params[:product_id] = scan['product_id'] : nil
		scan['asset_type_id'] ? scan_params[:asset_type_id] = scan['asset_type_id'] : nil

		scan_params[:location_id] = scan['location_id']
		scan_params[:tag] = {}

		# TAG
		print scan['tag']
		# Check T2 - T2-8983-1-43DDF-RF & convert to array
		if scan['tag'].count('-') == 4			
			scan['tag'] = scan['tag'].split('-')

		end

		if !scan['tag'][0].nil? 								# If array [0] nil, then must be hash
			# Check T1 - ["T1", 854,1,"43ddf","RF"]											
			if scan['tag'].kind_of?(Array)						# If array, assume tag version in [0]
				scan_params[:tag][:version] = scan['tag'][0].capitalize	
				if scan_params[:tag][:version] == 'T1' || scan_params[:tag][:version] == 'T2'
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
		return scan_params	
	end
end
