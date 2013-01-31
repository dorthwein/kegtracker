class Entity
  include Mongoid::Document
  include Mongoid::Timestamps  

	has_many :users
#	has_many :locations	
	has_many :products
	has_many :networks
	has_many :assets
	has_many :network_memberships
#	has_one :network

# Fields
	field :description, type: String    
	field :name, type: String
	field :street, type: String
	field :city, type: String
	field :state, type: String
	field :zip, type: String

# Entity Types
	field :distributor, type: Integer, :default => 0
	field :brewery, type: Integer, :default => 0
	field :lease, type: Integer, :default => 0
	field :account, type: Integer, :default => 0

# Entity Mode
	# 0 = Deactivated, 1 = Activated, 2 = Automated
	field :mode, type: Integer, :default => 0
end
