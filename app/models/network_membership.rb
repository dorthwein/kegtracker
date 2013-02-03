class NetworkMembership
  include Mongoid::Document
  belongs_to :network  # What network those permissions impact (Gives Power)
  belongs_to :entity # Who is given/has the permissions (Receives Power)

# Production
  field :product_production, type: Integer, :default => 0        	# allows filling of assets, production in fermentors

# Distribution
  field :asset_distribution, type: Integer, :default => 0      # allows delivery, picking and moving of assets	

# Leasing
  field :asset_leasing, type: Integer, :default => 0
  
# Reporting
  field :location_reporting, type: Integer, :default => 0	 	 # Grants visability to locations for owned assets/assets with your product

# Notes
# Future
#  field :production_reporting, type: Boolean	 # Grants visability to production 
#  field :inventory_reporting, type: Boolean	 	 # Grants visability to inventory
end
