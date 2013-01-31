class T0 < ScanDrone
	attr_accessor :version
	attr_accessor :value	
	attr_accessor :netid	
	attr_accessor :key	
	
	def initialize tag
		
=begin		
	{	
		"N":"1",
		"V":"24",
		"K":"asd34",
		"M":"1"
	}
{"N":"3","V":"36","K":"asd34","M":"1"}

=end
	# Check if valid JSON - 

		# Tag Array Map
		# 0 : Version
		# 1 : Value
		# 2 : NetID
		# 3 : Key		
		@version = '0'
		@value = tag['V']
		@netid = tag['N']
		@key = tag['K']	
	end
end
