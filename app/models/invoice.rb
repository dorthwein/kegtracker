class Invoice
  include Mongoid::Document
  include Mongoid::Timestamps  

  field :record_status, type: Integer, default: 1
  
	belongs_to :entity, index: true
	belongs_to :bill_to_entity, :class_name => 'Entity', index: true	# Billed to Entity - in-active

	field :invoice_number, type: String	
	field :date, :type => Time
	field :invoice_type, type: Integer

	field :entity_description, type: String
	field :bill_to_entity_description, type: String
	field :total_value, type: BigDecimal

	field :invoice_status, type: Integer # To be implemented

	has_many :invoice_line_items
	has_many :invoice_attached_assets

	has_many :invoice_details # To be depricated


	def invoice_detail_to_attached_asset
		self.invoice_details.each do |x|
			print "invoice conversion!"
			y = InvoiceAttachedAsset.find_or_create_by(
				product: x.product, 
				asset_type: x.asset_type, 
				invoice: self, 
				asset: x.asset
			)
			if y.save!
				print y.to_json
				print "\n \n"
			end
		end
	end


  	before_save :sync_descriptions    	
  	def sync_descriptions
  		self.entity_description = self.entity.description
  		self.bill_to_entity_description = self.bill_to_entity.description  		
  		self.update_line_item_attached_assets_count  	
	end

	def attach_asset options
		# Options: asset, asset_activity_fact
		invoice_attached_asset_record = self.invoice_attached_assets.find_or_create_by(asset_id: options[:asset]._id)

		invoice_attached_asset_record.update_attributes(
			invoice_id: self._id,
			asset_activity_fact_id: options[:asset].asset_activity_fact._id,
			product_id: options[:asset].asset_activity_fact.product_id,
    		asset_type_id: options[:asset].asset_activity_fact.asset_type_id,
    		sku_id: options[:asset].asset_activity_fact.sku_id,
			asset_id: options[:asset].asset_activity_fact.asset_id,    
		)		

		invoice_attached_asset_record.save!
		self.update_line_item_attached_assets_count
	end	

	def update_line_item_attached_assets_count 
  		self.invoice_line_items.each do |x|
  			attached_asset_count = x.invoice_attached_assets.count
  			if attached_asset_count == 0 && x.quantity == 0
  				x.destroy
  			else
  				x.update_attributes(invoice_attached_asset_count: attached_asset_count);
  			end
  		end		
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

