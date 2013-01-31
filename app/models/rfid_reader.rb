class RfidReader
  include Mongoid::Document  
  belongs_to :network
  has_many :rfid_antennas
  #  accepts_nested_attributes_for :rfid_antennas
  field :mac_address, type: String
  #  field :mac_address, type: String	# Validator  
  field :reader_name, type: String # Validator

  field :last_ip, type: String
  field :last_read, type: String
  field :command_port, type: Integer
  field :reader_type, type: String

#  def mac_address     
 #   mac_address = self.mac_address_1 + ':' + self.mac_address_2 + ':' + self.mac_address_3 + ':' + self.mac_address_4 + ':' + self.mac_address_5 + ':' + self.mac_address_6
  #  return mac_address
#  end
end
