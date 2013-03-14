class RfidReader
  include Mongoid::Document  
  field :record_status, type: Integer, default: 1

  belongs_to :network
  field :network_description, type: String

  belongs_to :entity
  field :entity_description, type: String  

  field :antenna_count, type: Integer    

  has_many :rfid_antennas
  #  accepts_nested_attributes_for :rfid_antennas
  field :mac_address, type: String
  #  field :mac_address, type: String	# Validator  
  field :reader_name, type: String # Validator

  field :last_ip, type: String
  field :last_read, type: String
  field :command_port, type: Integer
  field :reader_type, type: String

  before_save :sync_descriptions    
  def sync_descriptions
    self.network_description = self.network.description
    self.entity = self.network.entity
    self.entity_description = self.entity.description

    self.antenna_count = self.rfid_antennas.count
  end
end
