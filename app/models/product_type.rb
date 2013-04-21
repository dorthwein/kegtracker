class ProductType
  include Mongoid::Document
  include ExtendMongoid

	field :record_status, type: Integer, default: 1
	
	field :description, type: String    

	field :style, type: Integer	
	field :style_description, type: String

	field :origin, type: Integer
	field :origin_description, type: String

	def get_origin_description	
		case self.origin
		when 1

		when 2

		when 3

		when 4

		when 5

		end

	end

	field :notes, type: String    
	def get_style_description
		case self.style
		when 1
			return 'Ale'
		when 2
			return 'Lager'

		when 3
			return 'Hybrid/Mixed'
		end
	end
end
