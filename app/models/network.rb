class Network
  include Mongoid::Document
  include Mongoid::Timestamps  
  include ExtendMongoid

  field :record_status, type: Integer, default: 1

  auto_increment :netid, index: true #, type: Integer        # Unique

  field :description, type: String, :default => nil	
  field :tagCounter, type: Integer, :default => 1 # Maybe useless - See Barcode Maker
    
  # 1 = Brewery, 2 = Retail, 3 = Retail
  field :network_type, type: Integer, :default => 2

  # Depreicated
  field :market, type: Integer, :default => 0           
  field :distribution, type: Integer, :default => 0
  field :production, type: Integer, :default => 0

 # field :smart_mode, type: Integer, :default => 0   # When assets move in/out things occur to them
  field :auto_mode, type: Integer, :default => 1   

  belongs_to :smart_mode_product, :class_name => 'Product'
  belongs_to :smart_mode_in_location, :class_name => 'Location'     
  belongs_to :smart_mode_out_location, :class_name => 'Location'    

  field :smart_mode_product_description, type: String         
  field :smart_mode_in_location_description, type: String     
  field :smart_mode_out_location_description, type: String    

  field :entity_description, type: String
  field :network_type_description, type: String

# has_one :entity
  has_many :barcode_makers
  belongs_to :entity, index: true   
  has_many :locations

  def partner_locations
    self.locations.where(:location_type => 5)
  end
  def self.network_types
      network_types = [ 
                        {:_id => 1, :description => 'Brewery'},
                        {:_id => 2, :description => 'Distributor'},
                        {:_id => 3, :description => 'Retail'}
                      ]
    return network_types
  end

  def get_network_type_description
    case self.network_type.to_i
    when 1
      return 'Brewery' 
    when 2
      return 'Distributor'
    when 3
      return 'Retail'
    end
  end

	before_save :sync_descriptions	
  after_create :on_create  
	def sync_descriptions
    self.smart_mode_product_description = self.smart_mode_product.description
    self.smart_mode_in_location_description = self.smart_mode_in_location.description
    self.smart_mode_out_location_description = self.smart_mode_out_location.description

    self.entity_description = self.entity.description
    self.network_type_description = self.get_network_type_description

    if self.locations.count == 0
#      location = Location.create(:description => self.description, :network => self, :location_type => 6)
#      self.smart_mode_in_location = location
#      self.smart_mode_out_location = location

#      self.smart_mode_in_location_description = self.smart_mode_in_location.description
#      self.smart_mode_out_location_description = self.smart_mode_out_location.description    
    end
	end	


  def on_create
    if self.network_type == 1
      out_location = Location.create(:description => "Keg Room", :network => self, :location_type => 1)
      in_location = Location.create(:description => "Empty Keg Area", :network => self, :location_type => 2)
    elsif self.network_type == 2
      location = Location.create(:description => self.entity.description + "General Area", :network => self, :location_type => 1)
    end  
    self.smart_mode_in_location = in_location
    self.smart_mode_out_location = out_location

    self.smart_mode_in_location_description = self.smart_mode_in_location.description
    self.smart_mode_out_location_description = self.smart_mode_out_location.description    
  end

#  index({ entity_id: 1 }, { name: "entity_index" })
 # index({ description: 1 }, { name: "description_index" })
end
