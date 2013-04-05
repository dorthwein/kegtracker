class JqxConverter
	def self.jqxRecordLinkButton itm, options = {}
		return itm
	end
	def self.jqxDropDownList array, options = {}
		array.delete_if {|x| x == nil}
		array.map{|x| {:html => x[:description], :value => x[:_id] || x[:id]} }
	end

	def self.jqxListBox array
		array.map{|x| {:html => x[:description], :value => x[:_id] || x[:id]} }
	end

	def self.jqxGrid array, options = {}
		#x = array.delete_if{|k, v| v.nil?}
		return array
	end
end
