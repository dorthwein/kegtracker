class ProductionPartnership
	include Mongoid::Document
	include ExtendMongoid

	field :record_status, type: Integer, default: 1

	belongs_to :entity, :inverse_of => :entity, index: true  # Gives permissions right to Partner
  	belongs_to :partner, :class_name => 'Entity', :inverse_of => :entity, index: true	# Recieves permissions

	field :entity_description, type: String
	field :partner_description, type: String

	# Production
	field :production_partnership, type: Integer, :default => 0        	# allows filling of assets, production in fermentors  
	# Distribution
	field :distribution_partnership, type: Integer, :default => 0      # allows delivery, picking and moving of assets	
	# Leasing
	field :leasing_partnership, type: Integer, :default => 0

	field :partner_name, type: String
	field :partner_address_1, type: String
	field :partner_address_2, type: String
	field :partner_city, type: String
	field :partner_state, type: String
	field :partner_zip, type: String

	field :entity_name, type: String
	field :entity_address_1, type: String
	field :entity_address_2, type: String
	field :entity_city, type: String
	field :entity_state, type: String
	field :entity_zip, type: String


	before_save :sync_descriptions	
	def sync_descriptions
		# Ensure location_network is correct	
		self.entity_description = self.entity.description
		self.partner_description = self.partner.description

		self.partner_name = self.partner.name
		self.partner_address_1 = self.partner.address_1
		self.partner_address_2 = self.partner.address_2
		self.partner_city = self.partner.city
		self.partner_state = self.partner.state
		self.partner_zip = self.partner.zip

		self.entity_name = self.entity.name
		self.entity_address_1 = self.entity.address_1
		self.entity_address_2 = self.entity.address_2
		self.entity_city = self.entity.city
		self.entity_state = self.entity.state
		self.entity_zip	 = self.entity.zip
	end	 
end
