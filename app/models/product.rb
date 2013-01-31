class Product
  include Mongoid::Document
	has_many :assets
	belongs_to :entity
	belongs_to :product_type

	field :externalID, type: String  
	field :description, type: String
	field :upc, type: String		
	field :notes, type: String		
end
