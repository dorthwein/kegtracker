class InvoiceLineItem
	include Mongoid::Document
	include Mongoid::Timestamps  

	field :record_status, type: Integer, default: 1
	
	belongs_to :invoice, index: true
	belongs_to :entity, index: true
	has_many :invoice_attached_assets
#	belongs_to :price
	
	belongs_to :sku
	belongs_to :asset_type
	
	belongs_to :product
#	field :description, type: String	

	field :sku_description, type: String
	field :asset_type_description, type: String
	field :product_description, type: String

	field :quantity, type: Integer, default: 0
	field :invoice_attached_asset_count, type: Integer, default: 0

=begin	
	field :base_tier, type: Integer
	field :base_tier_description, type: String

	field :unit_price, type: BigDecimal, default: 0
	field :unit_sales_tax, type: BigDecimal, default: 0
	field :unit_gallonage_tax, type: BigDecimal, default: 0	
	field :unit_total_tax, type: BigDecimal, default: 0

	field :total_price, type: BigDecimal, default: 0
	field :total_sales_tax, type: BigDecimal, default: 0
	field :total_gallonage_tax, type: BigDecimal, default: 0

	field :total_tax, type: BigDecimal, default: 0
	field :total, type: BigDecimal, default: 0
=end

=begin
	before_create :add_to_invoice
	def add_to_invoice
#		self.unit_value = self.price.price * self.quantity
	
		self.unit_price = self.price.price
		self.unit_sales_tax = self.price.sales_tax
		self.unit_gallonage_tax = self.price.gallonage_tax 
		self.unit_total_tax = self.unit_gallonage_tax + self.unit_sales_tax

		self.total_price = self.unit_price * self.quantity 
		self.total_sales_tax = self.unit_sales_tax * self.quantity 
		self.total_gallonage_tax = self.unit_gallonage_tax * self.quantity 		

		self.total_tax = self.total_sales_tax + self.total_gallonage_tax
	
		self.total = self.total_tax + self.total_price
	end
=end

	def find_or_create_by_invoice_attached_asset
		# Created w


	end

	def get_base_tier_description
	case self.base_tier.to_i
		when 1
		  return 'Unit' 
		when 2
		  return 'Consumer Pk.'
		when 3
		  return 'Case'
		when 4
		  return 'Pallet'
		end
	end

	def self.base_tiers
		base_price_tiers = [ 
	                    {:_id => 1, :description => 'Unit'},
	                    {:_id => 2, :description => 'Consumer Pk.'},
	                    {:_id => 3, :description => 'Case'},
	                    {:_id => 4, :description => 'Pallet'}
	                  ]
		return base_tiers
	end
	

	before_save :sync_descriptions
	def sync_descriptions
		self.sku_description = self.sku.description		
		self.entity_id = self.invoice.entity_id

#		self.base_tier_description = self.get_base_tier_description		
#		self.total_tax = self.total_sales_tax + self.total_gallonage_tax
#		self.total = self.total_tax + self.total_price
#		self.sku_id = self.price.sku_id		

#		self.sku_description = self.sku.description		
#		if self.description.nil?
#			self.description = self.sku_description
#		end

#		self.invoice_detail_type_description = get_invoice_detail_type_description
#		self.product_description = self.product.description
#		self.product_entity_description = self.product.entity.description

#		self.asset_type_description = self.asset_type.description
#		self.asset_status_description = get_asset_status_description
#		self.invoice_detail_description = self.get_invoice_detail_description		
	end
end
