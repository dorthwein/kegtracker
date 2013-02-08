class Invoice
  include Mongoid::Document
  
	belongs_to :invoice_entity, :class_name => 'Entity'
	belongs_to :bill_entity, :class_name => 'Entity'

	field :number, type: String
	
	belongs_to :production_invoice, :class_name => 'Invoice'


	field :date, :type => Time
	field :type, type: Integer

	has_many :invoice_asset_facts

	


	def type_description
		case self.type.to_i
		when 1
			return 'Production'	
		when 2
			return 'Distributor'
#		when 3
#			return 'Market'
		end	
	end
end
