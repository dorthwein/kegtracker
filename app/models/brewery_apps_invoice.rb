class BreweryAppsInvoice
  include Mongoid::Document
  include Mongoid::Timestamps  	

  	belongs_to :bill_to_entity, :class_name => 'Entity'

  	field :first_name, type: String
  	field :last_name, type: String

	field :address_1, type: String
	field :address_2, type: String	
	field :city, type: String
	field :state, type: String
	field :zip, type: String

	# 1 = Current, 2 = Pending Payment, 3 = Paid
	field :status, type: Integer

  	field :billing_period_month, type: Integer
  	field :billing_period_year, type: Integer  	

end
