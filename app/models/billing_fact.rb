class BillingFact
  include Mongoid::Document
  include Mongoid::Timestamps  	
  include ExtendMongoid  
# 1 = Active, 0 = Deleted, 
	field :record_status, type: Integer, default: 1	
  
# Daily fact rendering services used for that day.
	field :fact_time, type: Time
	belongs_to :bill_to_entity, :class_name => 'Entity'
	field :bill_to_entity_description, type: String
	
	field :kt_assets, type: Array
	field :kt_ce_days, type: BigDecimal, default: 0
	field :kt_rate, type: BigDecimal, default: 0
	field :kt_charge, type: BigDecimal, default: 0

	field :paid, type: Integer, default: 0

	before_save :sync_descriptions  
	def sync_descriptions
		self.bill_to_entity_description = bill_to_entity.description
	end
end
