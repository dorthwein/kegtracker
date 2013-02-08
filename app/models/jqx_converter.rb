class JqxConverter
	def self.jqxDropDownList array, options = {}
		array.map{|x| {:html => x[:description], :value => x[:_id] || x[:id]} }
	end

	def self.jqxGrid array, options = {}
		array.map{|x| x.attributes	}			
	end
end
