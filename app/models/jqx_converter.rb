class JqxConverter
	def self.jqxDropDownList array, options = {}
		array.map{|x| {:html => x[:description], :value => x[:_id] || x[:id]} }
	end

	def self.jqxGrid array, options = {}
		a = []
		array.each do |x|
			z = {}
			x.attributes.each do |k,v|
			 	if v.instance_of?(Time)
			 		z[k] = v.strftime("%b %d, %Y")  
			 	else
			 		z[k] = v
			 	end			 	
			end
			a.push(z)
		end
		return a
	end
end
