class EntityPartnership
  include Mongoid::Document
  belongs_to :entity, :inverse_of => :entity  		# Gives permissions
  belongs_to :partner, :class_name => 'Entity', :inverse_of => :entity	# Recieves 

  field :entity_description, type: String
  field :partner_description, type: String

# Production
  field :production_partnership, type: Integer, :default => 0        	# allows filling of assets, production in fermentors  
# Distribution
  field :distribution_partnership, type: Integer, :default => 0      # allows delivery, picking and moving of assets	
# Leasing
  field :leasing_partnership, type: Integer, :default => 0
  
  	field :partner_name, type: String
	field :partner_street, type: String
	field :partner_city, type: String
	field :partner_state, type: String
	field :partner_zip, type: String

  	field :entity_name, type: String
	field :entity_street, type: String
	field :entity_city, type: String
	field :entity_state, type: String
	field :entity_zip, type: String


	before_save :sync_descriptions	
	def sync_descriptions
		# Ensure location_network is correct	
		self.entity_description = self.entity.description
		self.partner_description = self.partner.description

		self.partner_name = self.partner.name
		self.partner_street = self.partner.street
		self.partner_city = self.partner.city
		self.partner_state = self.partner.state
		self.partner_zip = self.partner.zip

		self.entity_name = self.entity.name
		self.entity_street = self.entity.street
		self.entity_city = self.entity.city
		self.entity_state = self.entity.state
		self.entity_zip	 = self.entity.zip
	end	 
end
