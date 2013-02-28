
class Price
  include Mongoid::Document
	belongs_to :sku
	field :sku_description, type: String

	belongs_to :entity
	field :entity_description, type: String
	
	belongs_to :bill_to_entity, class_name: 'Entity'
	field :bill_to_entity_description, type: String

	field :sku_tier_1_price, type: BigDecimal
	field :sku_tier_2_price, type: BigDecimal
	field :sku_tier_3_price, type: BigDecimal
	field :sku_tier_4_price, type: BigDecimal

	field :sku_tier_1_tax, type: BigDecimal
	field :sku_tier_2_tax, type: BigDecimal
	field :sku_tier_3_tax, type: BigDecimal
	field :sku_tier_4_tax, type: BigDecimal

	has_and_belongs_to_many :tax_rules

	before_save :sync_descriptions		
	def sync_descriptions		
		self.sku_description = self.sku.sku_description

		self.entity_description = self.entity.entity.description		
		self.bill_to_entity_description = self.bill_to_entity.entity.description
	end	
end

