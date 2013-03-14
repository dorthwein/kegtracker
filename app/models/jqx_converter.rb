class JqxConverter
	def self.jqxDropDownList array, options = {}
		array.map{|x| {:html => x[:description], :value => x[:_id] || x[:id]} }
	end

	def self.jqxListBox array
		array.map{|x| {:html => x[:description], :value => x[:_id] || x[:id]} }
	end

	def self.jqxGrid array, options = {}
		return array
	end
end
