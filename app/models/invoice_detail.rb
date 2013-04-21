class InvoiceDetail
# Being Depricated
	include Mongoid::Document
    include ExtendMongoid	
    
	field :record_status, type: Integer, default: 1
	belongs_to :invoice
	belongs_to :asset
	belongs_to :asset_activity_fact
	belongs_to :asset_type
	belongs_to :product
	
	field :invoice_detail_type, type: Integer
	field :invoice_detail_type_description, type: Integer
	field :invoice_detail_description, type: String
	field :asset_type_description, type: String
	field :product_description, type: String
	field :product_entity_description, type: String

	field :asset_status, type: Integer
	field :asset_status_description, type: String

	def get_invoice_detail_description
		case self.invoice_detail_type.to_i
		when 1
			return self.get_asset_invoice_detail_description
		else
			return 'Unknown'
		end
	end

	def get_asset_invoice_detail_description
		case self.asset_status.to_i
		when 0
			return "#{self.asset_type_description} (#{self.asset_status_description})"
		when 1
			return "#{self.product_description}  (#{self.asset_type_description})"
		when 2
			return "#{self.product_description}  (#{self.asset_type_description})"
		when 3
			return "#{self.asset_type_description} (#{self.asset_status_description})"
		when 4
			return "#{self.asset_type_description} (#{self.asset_status_description})"
		else
			return 'Unknown'	
		end
	end

	def get_invoice_detail_type_description
		case self.invoice_detail_type.to_i
		when 1
			return 'Asset'
		else
			return 'Unknown' 
		end
	end

	def get_asset_status_description
		case self.asset_status.to_i
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

	before_create :build_invoice_detail
	def build_invoice_detail 
		case self.invoice_detail_type.to_i
		when 1
			self.asset = self.asset_activity_fact.asset
			self.product = self.asset_activity_fact.product
			self.asset_type = self.asset_activity_fact.asset_type
			self.asset_status = self.asset_activity_fact.asset_status			
		else
			return 'Unknown'
		end		
	end

	before_save :sync_descriptions		
	def sync_descriptions
		self.invoice_detail_type_description = get_invoice_detail_type_description

		self.product_description = self.product.description
		self.product_entity_description = self.product.entity.description


		self.asset_type_description = self.asset_type.description
		self.asset_status_description = get_asset_status_description
		self.invoice_detail_description = self.get_invoice_detail_description		
	end
end

