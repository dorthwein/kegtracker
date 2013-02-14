class HandleCode
	def self.get_description x
		case x.to_i
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
end
