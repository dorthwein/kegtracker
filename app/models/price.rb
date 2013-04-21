class Price
  include Mongoid::Document
  include ExtendMongoid

  	field :record_status, type: Integer, default: 1
  	
  	field :description, type: String

	belongs_to :sku
	field :sku_description, type: String

	belongs_to :entity
	field :entity_description, type: String
	
#	belongs_to :bill_to_entity, class_name: 'Entity'
#	field :bill_to_entity_description, type: String

	field :price, type: BigDecimal
	field :sales_tax, type: BigDecimal
	field :gallonage_tax, type: BigDecimal
	field :total_tax, type: BigDecimal
	field :total, type: BigDecimal

	# 1 = Unit, 2 = Consumer Pk., 3 = Case, 4 = Pallet
	field :base_price_tier, type: Integer	
	field :base_price_tier_description, type: String	

=begin
	field :sku_tier_1_price, type: BigDecimal
	field :sku_tier_2_price, type: BigDecimal
	field :sku_tier_3_price, type: BigDecimal
	field :sku_tier_4_price, type: BigDecimal

	field :sku_tier_1_sales_tax, type: BigDecimal
	field :sku_tier_2_sales_tax, type: BigDecimal
	field :sku_tier_3_sales_tax, type: BigDecimal
	field :sku_tier_4_sales_tax, type: BigDecimal

	field :sku_tier_1_gallonage_tax, type: BigDecimal
	field :sku_tier_2_gallonage_tax, type: BigDecimal
	field :sku_tier_3_gallonage_tax, type: BigDecimal
	field :sku_tier_4_gallonage_tax, type: BigDecimal

	field :sku_tier_1_total_tax, type: BigDecimal
	field :sku_tier_2_total_tax, type: BigDecimal
	field :sku_tier_3_total_tax, type: BigDecimal
	field :sku_tier_4_total_tax, type: BigDecimal
=end

	def get_base_price_tier_description
	case self.base_price_tier.to_i
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

	def self.base_price_tiers
		base_price_tiers = [
	                    {:_id => 1, :description => 'Unit'},
	                    {:_id => 2, :description => 'Consumer Pk.'},
	                    {:_id => 3, :description => 'Case'},
	                    {:_id => 4, :description => 'Pallet'}
	                  ]
		return base_price_tiers
	end

	before_save :sync_descriptions
	def sync_descriptions
		self.total_tax = self.sales_tax + self.gallonage_tax
		self.total = "%.2f" % (self.price + self.sales_tax + self.gallonage_tax)
		self.base_price_tier_description = self.get_base_price_tier_description
		
		self.sku_description = self.sku.description
		
		self.description = '$' + self.price.to_s + '/' + base_price_tier_description + ' - ' + self.sku_description
		self.entity_description = self.entity.description		
#		self.bill_to_entity_description = self.bill_to_entity.description
	end	
end
