class BreweryAppsInvoiceLineItem
  include Mongoid::Document
  include Mongoid::Timestamps  	

	belongs_to :entity
  # 1 = KegTracker, 2 = KegReg,  
	belongs_to :brewery_apps_invoice
	field :subscription_code, type: Integer

	field :billable_units, type: BigDecimal
	field :billing_rate, type: BigDecimal
	field :total, type: BigDecimal, default: 0.00

	def get_subscription_description
		case self.subscription_code.to_i
		when 1
			return 'KegTracker'	
		when 2
			return 'KegReg'
		end
	end	  
end