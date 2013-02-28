class InvoiceLineItems
	include Mongoid::Document

	belongs_to :invoice
	belongs_to :sku  # To be created
	belongs_to :asset_type
	belongs_to :product

	field :description, type: String
	field :quantity, type: Integer

	field :unit_value, type: BigDecimal
	field :tax_value, type: BigDecimal 

	field :total_value, type: BigDecimal
	
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

