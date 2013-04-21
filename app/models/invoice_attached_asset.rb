class InvoiceAttachedAsset
  include Mongoid::Document
  include Mongoid::Timestamps  
  include ExtendMongoid
    
	field :record_status, type: Integer, default: 1
	
	belongs_to :invoice, index: true
	belongs_to :invoice_line_item, index: true
	belongs_to :asset, index: true
	

	belongs_to :asset_activity_fact

	belongs_to :asset_type
	belongs_to :product
	belongs_to :sku
	

	field :asset_type_description, type: String
	field :product_description, type: String
	field :product_entity_description, type: String


	after_destroy :removal
	# Create Attachment rollback
	def removal
		self.invoice.update_line_item_attached_assets_count		
	end

	before_save :sync_descriptions		
	def sync_descriptions
		self.sku = Sku.find_or_create_by(entity: self.product.entity, primary_asset_type: self.asset_type, product: self.product)
		self.invoice_line_item = self.invoice.invoice_line_items.find_or_create_by(sku: self.sku)

#		invoice_attached_assets_count = self.invoice.invoice_attached_assets.where(sku: self.sku).count
#		self.invoice.invoice_attached_asset_count = invoice_attached_assets_count

		self.product_description = self.product.description
		self.product_entity_description = self.product.entity.description
		self.asset_type_description = self.asset_type.description
	end
end

