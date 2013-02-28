class TaxRule
  include Mongoid::Document
	has_and_belongs_to_many :prices

	field :tax_rule_type_description, type: String
	field :tax_rule_type, type: Integer	

	def get_tax_rule_type_description x
		case x.to_i
		when 1
			return 'Gallonage/Barrelage'	
		when 2
			return 'Sales'	
		end
	end

  def self.tax_rule_types
    response = [ 
        {:description => 'Inventory', :_id => 1},
        {:description => 'Empty Assets', :_id => 2},
        {:description => 'Market', :_id => 3},
        {:description => 'Production', :_id => 4},
        {:description => 'Partner', :_id => 5},
        {:description => 'General Area', :_id => 6},        
    ]
    return response
end

