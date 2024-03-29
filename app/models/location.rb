class Location
  include Mongoid::Document
  include Mongoid::Timestamps  
  include ExtendMongoid

  field :record_status, type: Integer, default: 1
  
  field :description, type: String    
  field :externalID, type: String

  field :name, type: String
  field :street, type: String
  field :city, type: String
  field :state, type: String
  field :zip, type: String

  field :asset_count, type: Integer

  field :location_type, type: Integer, :default => 6
  field :location_type_description, type: String

  # 0 = Private, 1 = Partners, 
  field :scope, type: Integer, :default => 0
  field :scope_description, type: String

  has_many :assets
  
  # Relations
  belongs_to :entity, index: true
  belongs_to :network, :inverse_of => :location, index: true
  
  # De-normalized
  field :entity_description, type: String
  field :network_description, type: String

  def self.location_types
    response = [
        {:description => 'Inventory', :_id => 1},
        {:description => 'Empty Assets', :_id => 2},
        {:description => 'Market', :_id => 3},
#        {:description => 'Production', :_id => 4},
#        {:description => 'Partner', :_id => 5},
#        {:description => 'General Area', :_id => 6},
    ]
    return response
  end

  def get_location_type_description
    case self.location_type.to_i
    when 1
      return 'Inventory' 
    when 2
      return 'Empty Assets'
    when 3
      return 'Market'
    when 4
      return 'Production'
    when 5
      return 'Partner'
    when 6
      return 'General Area'
    end
  end

	before_save :sync_descriptions
	def sync_descriptions
    self.entity = self.network.entity
    self.scope_description = self.scope == 0 ? 'Private' : self.scope == 1 ? 'Public' : ' '

		self.network_description = self.network.description
		self.entity_description = self.entity.description		
    self.location_type_description = self.get_location_type_description

    self.asset_count = Asset.where(:location => self).count
	end
#  index({ entity_id: 1 }, { name: "entity_index" })          
#  index({ network_id: 1 }, { name: "network_index" })  
end

