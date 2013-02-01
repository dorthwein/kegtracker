=begin
class S1 < ScanDrone	
	# User
	attr_accessor :email
	attr_accessor :password
	
	# Processing
	attr_accessor :handle_code
	attr_accessor :time
	attr_accessor :asset_type
	attr_accessor :product
	
	# Locations	
	attr_accessor :location
	
	# Tag
	attr_accessor :tag_version
	attr_accessor :value	
	attr_accessor :network	
	attr_accessor :key	

	def initialize scan		
		error = {:error => 0, :error_code => 0, :error_message => 'No Errors' };

=begin	
	scan = {
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
	

	# *************	
	# Scan Parsing
	# *************	
		# User
		@email = scan['user']['N']
		@password = scan['user']['P']
	
		# Processing
		@handle_code = scan['processing']['HC']
		@time = scan['processing']['T']
		scan['processing']['P'] ? @product = scan['processing']['P'] : nil
		scan['processing']['AT'] ? @asset_type = scan['processing']['AT'] : nil
		
		# Location
		@location = Location.find(scan['location'])
		# TAG -- Loads Tag Parser
		if !scan['tag'][0].nil? && (scan['tag'].kind_of?(Array) || scan['tag'].kind_of?(Hash)) # Check For Tag Version
			@tag_version = scan['tag'][0].capitalize
			tag = Object.const_get(tag_version).new scan['tag']

			@value = tag.value
			@network = Network.where(:netid => tag.netid).first
			@key = tag.key						
		else
			# Default to T0			
			@tag_version = 'T0'	# scan['tag'][0].capitalize

			tag = Object.const_get(tag_version).new scan['tag']			
			@value = tag.value

			# Default - Check for Network
			if tag.netid.nil?
				@network = @location.network
			else
				@network = Network.where(:netid => tag.netid).first
			end
			
			# Default - Check for Key
			if tag.key.nil?
				@key = 0
			else
				@key = tag.key									
			end			

		end	
	end
end
=end