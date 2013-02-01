=begin
class T1 < ScanDrone
	attr_accessor :version
	attr_accessor :value	
	attr_accessor :netid	
	attr_accessor :key	
	
	def initialize tag
	
		# Tag Array Map
		# 0 : Version
		# 1 : Value
		# 2 : NetID
		# 3 : Key
		# 4 : TYPE (i.e. RF v.s. Sticker)
		# ["T1",353,1,"12345","RF"]
		
		@version = tag[0]
		@value = tag[1]
		@netid = tag[2]
		@key = tag[3]		
	end
end
=end