class Invoice
  include Mongoid::Document
  
	belongs_to :invoice_entity, :class_name => 'Entity' # Owner
	belongs_to :bill_entity, :class_name => 'Entity'	# Billed to Entity - in-active

	field :number, type: String	
	field :date, :type => Time
	field :invoice_type, type: Integer

	field :invoice_entity_description, type: String
	field :bill_entity_description, type: String
	field :total_value, type: BigDecimal

	field :invoice_status, type: Integer # To be implemented

	has_many :invoice_details
  	before_save :sync_descriptions  
  	
  	def sync_descriptions
  		self.invoice_entity_description = self.invoice_entity.description
  		if !self.bill_entity.nil?
  			self.bill_entity_description = self.bill_entity.description
  		end
	end

	def add_invoice_asset_detail options
		self.invoice_details.where(:asset => options[:asset]).destroy_all
		invoice_detail = InvoiceDetail.create(:invoice_detail_type => 1, :asset_activity_fact => options[:asset_activity_fact] )
		invoice_detail.update_attributes(:invoice => self)		

		return invoice_detail
	end

	def invoice_type_description
		case self.type.to_i
		when 1
			return 'Production'	
		when 2
			return 'Distributor'
#		when 3
#			return 'Market'
		else 
			return 'Unknown'
		end	
	end
end
