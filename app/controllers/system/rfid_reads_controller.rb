class System::RfidReadsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def read
	@rfid_read = params[:Alien_RFID_Reader_Auto_Notification]
	#rfid_read = params[:Alien_RFID_Reader_Auto_Notification]
	# ["T1",353,1,"12345","RF" ]	
	# CHECK FOR READER FROM MAC-ADDRESS
	@rfid_reader = RfidReader.where(:mac_address => @rfid_read['MACAddress'], :_id => @rfid_read['ReaderName']).first
	
	

	# LOAD ANTENNAS SETTINGS SETTINGS
	rfid_antennas = @rfid_reader.rfid_antennas.asc(:antenna_number)

	# CREATE SCANS ARRAY
	scans_array = Array.new

	# THINGS IN SCANS BUT NOT RIFD
		# (1) AUTO MODE SELECTION
		# (2) INVOICEING

	# FOR EACH TAG 
	if !params[:Alien_RFID_Reader_Auto_Notification]['Alien_RFID_Tag_List']['Alien_RFID_Tag'].nil?
		params[:Alien_RFID_Reader_Auto_Notification]['Alien_RFID_Tag_List'].each do |tag| 	
			if !tag[1].instance_of?(Array)
				tag_id = tag[1]['TagID'].delete(' ')	
				tag_antenna = tag[1]['Antenna'].to_i				
				new_str = ''
				
				arr = tag_id.split('')
				arr.in_groups_of(2){|c| new_str << ("#{c[0]}#{c[1]}".hex.chr) }
				new_str = JSON.parse(new_str)  || nil
				
				scan = Hash.new
				scan['version'] = 'S1'

				scan['user'] = Hash.new
				scan['user']['N'] = 'd.orthwein@lipmanbrothers.com'
				scan['user']['P'] = 'system_rfid_pass'

				scan['processing'] = Hash.new
				scan['processing']['HC'] = rfid_antennas[tag_antenna].handle_code
				scan['processing']['T'] = Time.now.to_i

				scan['processing']['auto_mode'] = 1

				if !rfid_antennas[tag_antenna].product.nil?
					scan['processing']['P'] = rfid_antennas[tag_antenna].product._id
				end
				if !rfid_antennas[tag_antenna].asset_type.nil?
					scan['processing']['AT'] = rfid_antennas[tag_antenna].asset_type._id
				end
				
				scan['location'] = rfid_antennas[tag_antenna].location._id
				scan['tag'] = new_str
				
=begin				
				scan = { 
					:version => 'S1',
					:user => {
						:N => 'd.orthwein@lipmanbrothers.com',
						:P => 'system_rfid_pass'
					},
					:processing => {
						:HC => rfid_antennas[tag_antenna].handle_code.code,
						:T => Time.now.to_i,
						:P => rfid_antennas[tag_antenna].product._id,
						:AT => rfid_antennas[tag_antenna].asset_type._id,
					},
					:location => rfid_antennas[tag_antenna].location._id,
					:tag => new_str # tag['TagID']
				}
=end
		
				scans_array.push(scan.to_json)		
			else
				tag[1].each do |tag_read|
					tag_id = tag_read['TagID'].delete(' ')	
					tag_antenna = tag_read['Antenna'].to_i				
					new_str = ''
					
					arr = tag_id.split('')
					arr.in_groups_of(2){|c| new_str << ("#{c[0]}#{c[1]}".hex.chr) }
					new_str = JSON.parse(new_str) rescue break
					
					scan = Hash.new
					scan['version'] = 'S1'
	
					scan['user'] = Hash.new
					scan['user']['N'] = 'd.orthwein@lipmanbrothers.com'
					scan['user']['P'] = 'system_rfid_pass'
	
					scan['processing'] = Hash.new
					scan['processing']['HC'] = rfid_antennas[tag_antenna].handle_code
					scan['processing']['T'] = Time.now.to_i
					scan['processing']['auto_mode'] = 1
	
					if !rfid_antennas[tag_antenna].product.nil?
						scan['processing']['P'] = rfid_antennas[tag_antenna].product._id
					end
					if !rfid_antennas[tag_antenna].asset_type.nil?
						scan['processing']['AT'] = rfid_antennas[tag_antenna].asset_type._id
					end
					
					scan['location'] = rfid_antennas[tag_antenna].location._id
					scan['tag'] = new_str


=begin					
					scan = { 
						:version => 'S1',
						:user => {
							:N => 'd.orthwein@lipmanbrothers.com',
							:P => 'system_rfid_pass'
						},
						:processing => {
							:HC => rfid_antennas[tag_antenna].handle_code.code,
							:T => Time.now.to_i,
							:P => rfid_antennas[tag_antenna].product._id,
							:AT => rfid_antennas[tag_antenna].asset_type._id,
						},
						:location => rfid_antennas[tag_antenna].location._id,
						:tag => new_str # tag['TagID']
					}
=end				
					scans_array.push(scan.to_json)
				end				
			end			
		end

#		RfLog.create( 
#			:raw_data => params[:Alien_RFID_Reader_Auto_Notification],
#			:scan_array => scans_array
#		)
		Scanner.process_scans({:scans => scans_array})
		# Asset.process_scans({:scans => scans_array})
		print "READ END \n \n"		
	end
#	print @scans.to_json
	
	# CHECK FOR READER FROM MAC-ADDRESS
	
	# LOAD EACH ANTENNAS SETTINGS SETTINGS
	
	# CREATE SCANS ARRAY
	
	# FOR EACH TAG 
		# CHECK ANTENNA
		# CONSTRUCT SCAN
		# APPLY ATNENNA SETTINGS
		#
	
=begin	
	scan = {
		version : 'Scan Version',
		user : {
			N: 'NAME',
			p: 'PASSWORD',
		},
		processing : {
			HC: 'Handle Code',
			T: 'Time',
			P: 'Product',
			AT: 'Asset Type',
		},
		location : 'LOCATION_ID',
		TAG : 'TAG BASED ON TAG PARSER'
	}
=end	  	  
# end  	
    respond_to do |format|
    	format.xml
        format.html { head :no_content }
	end

  end
end
