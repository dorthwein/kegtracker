class Product
  include Mongoid::Document
	has_many :assets
	belongs_to :entity
	belongs_to :product_type


	field :entity_description, type: String  
	field :product_and_entity_description, type: String  

	field :product_type_description, type: String



	field :externalID, type: String  
	field :description, type: String
	field :upc, type: String		
	field :notes, type: String		

	before_save :sync_descriptions		
	def sync_descriptions
		self.entity_description = self.entity.description
		self.product_and_entity_description = self.product.description + " (#{self.entity_description})"
		self.product_type_description = self.product_type.description
	end
end
