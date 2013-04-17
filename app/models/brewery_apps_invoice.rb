class BreweryAppsInvoice
  include Mongoid::Document
  include Mongoid::Timestamps  	

  	belongs_to :bill_to_entity, :class_name => 'Entity'
  	has_many :brewery_apps_invoice_line_items
  	
  	has_many :billing_facts

  	field :billing_first_name, type: String
  	field :billing_last_name, type: String

	field :billing_address_1, type: String
	field :billing_address_2, type: String	
	field :billing_city, type: String
	field :billing_state, type: String
	field :billing_zip, type: String


	field :payment_token, type: String
	field :payment_date, type: Time
	field :payment_card_ending, type: String

	field :invoice_number, type: Integer
	
	# 1 = Current, 2 = Pending Payment, 3 = Paid
	field :status, type: Integer

  	field :billing_period_start, type: Time
  	field :billing_period_end, type: Time

  	field :total, type: BigDecimal, default: 0.00

	
	def get_status_description
		case self.status.to_i
		when 1
			return 'Current'	
		when 2
			return 'Pending'
		when 3
			return 'Paid'
		end
	end	
end
