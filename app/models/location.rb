
class Location
  include Mongoid::Document
  include Mongoid::Timestamps  
  
  field :description, type: String    
  field :externalID, type: String

  field :name, type: String
  field :street, type: String
  field :city, type: String
  field :state, type: String
  field :zip, type: String

  field :on_premise, type: Integer    
  field :off_premise, type: Integer
  field :empty, type: Integer
  field :inventory, type: Integer  
  field :production, type: Integer  
  field :partner_entity, type: Integer

  has_many :assets
  
  # Relations
  belongs_to :entity
  belongs_to :network, :inverse_of => :location
  
  # De-normalized
  field :entity_description, type: String
  field :network_description, type: String

	before_save :sync_descriptions
	def sync_descriptions
    self.entity = self.network.entity
		self.network_description = self.network.description
		self.entity_description = self.entity.description		
	end


  index({ entity_id: 1 }, { name: "entity_index" })          
  index({ network_id: 1 }, { name: "network_index" })  

end