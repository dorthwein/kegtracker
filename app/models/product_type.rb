class ProductType
  include Mongoid::Document
	field :description, type: String    
	field :notes, type: String    
end
