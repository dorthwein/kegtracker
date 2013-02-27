class Sku
  include Mongoid::Document
	belongs_to :product
	field :product_description, type: String	
	belongs_to :entity

	field :description, type: String	
	field :item_number, type: String

	field :tier_1_description, type: String
	field :tier_1_upc, type: String # Typically Bottle
	belongs_to :tier_1_asset_type, :class_name => 'AssetType', :inverse_of => :sku 
	field :tier_1_asset_type_description, type: String	
	field :tier_1_qty_per_tier_2, type: Integer

	field :tier_2_description, type: String
	field :tier_2_upc, type: String # Typically Consumer Pack
	belongs_to :tier_2_asset_type, :class_name => 'AssetType', :inverse_of => :sku 
	field :tier_2_asset_type_description, type: String
	field :tier_2_qty_per_tier_3, type: Integer


	field :tier_3_description, type: String
	field :tier_3_upc, type: String # Typically Case
	belongs_to :tier_3_asset_type, :class_name => 'AssetType', :inverse_of => :sku 
	field :tier_3_asset_type_description, type: String
	field :tier_3_qty_per_tier_4, type: Integer

	field :tier_4_description, type: String
	field :tier_4_upc, type: String # Typically Pallet	
	belongs_to :tier_4_asset_type, :class_name => 'AssetType', :inverse_of => :sku 
	field :tier_4_asset_type_description, type: String

	before_save :sync_descriptions		
	def sync_descriptions
		self.product_description = self.product.description
		self.tier_1_asset_type_description = self.tier_1_asset_type.description.to_s
		self.tier_2_asset_type_description = self.tier_2_asset_type.description.to_s
		self.tier_3_asset_type_description = self.tier_3_asset_type.description.to_s
		self.tier_4_asset_type_description = self.tier_4_asset_type.description.to_s

		self.tier_1_description = self.product.description.to_s + ' (' + self.tier_1_asset_type_description.to_s + ')'
		self.tier_2_description = self.product.description.to_s + ' (' + self.tier_2_asset_type_description.to_s + ')'
		self.tier_3_description = self.product.description.to_s + ' (' + self.tier_3_asset_type_description.to_s + ')'
		self.tier_4_description = self.product.description.to_s + ' (' + self.tier_4_asset_type_description.to_s + ')'
		
		self.description = self.product.description.to_s + ' - ' + self.tier_1_asset_type_description.to_s	
	end
end
