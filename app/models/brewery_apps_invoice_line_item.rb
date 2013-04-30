class BreweryAppsInvoiceLineItem
  include Mongoid::Document
  include Mongoid::Timestamps  	
  include ExtendMongoid
  
# 1 = Active, 0 = Deleted, 
	field :record_status, type: Integer, default: 1	

	belongs_to :entity
  # 1 = KegTracker, 2 = KegReg,  
	belongs_to :brewery_apps_invoice
	field :subscription_code, type: Integer

	field :billable_units, type: BigDecimal, default: 0
	field :billing_rate, type: BigDecimal, default: 0
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
