class AssetStatus
	def get_description x
		case x.to_i
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
end
