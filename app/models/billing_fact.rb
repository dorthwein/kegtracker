class BillingFact
  include Mongoid::Document
  include Mongoid::Timestamps  	
  
# Daily fact rendering services used for that day.
	field :fact_time, type: Time
	belongs_to :bill_to_entity, :class_name => 'Entity'
	field :bill_to_entity_description, type: String
	
	field :kt_assets, type: Array
	field :kt_ces, type: BigDecimal
	field :kt_ce_rate, type: BigDecimal
	field :kt_charge, type: BigDecimal

	field :paid, type: Integer, default: 0

	before_save :sync_descriptions  
	def sync_descriptions
		self.bill_to_entity_description = bill_to_entity.description
	end
end
