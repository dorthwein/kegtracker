class Entity
  include Mongoid::Document
  include Mongoid::Timestamps  

	has_many :users
	has_many :locations	
	has_many :products
	has_many :networks
	has_many :assets
	has_many :network_memberships
	
	has_many :entity_partnerships_as_partner, :class_name => 'EntityPartnership', :inverse_of => :partner
	has_many :entity_partnerships_as_entity, :class_name => 'EntityPartnership', :inverse_of => :entity
#	has_many :entity_partnerships_as_entity, as: :entity_partnerships_as_entity
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

##################
# Class Methods  #
##################

	def self.distribution_entities
		# Entities /w at least 1 distribution network
		 return Network.where(:network_type => 2).group_by{|x| x.entity}.map{|x| x[0]}	
	end
	def self.production_entities	
		return Network.where(:network_type => 1).group_by{|x| x.entity}.map{|x| x[0]}	
	end
	
#############################
# Distribution Partnerships #
#############################
	def distribution_partnerships_as_partner
		# Where current user is partner
		self.entity_partnerships_as_partner.where(:distribution_partnership => 1)

	end
	def distribution_partnerships_as_entity
		# Where current user is entity
		self.entity_partnerships_as_entity.where(:distribution_partnership => 1)

	end
	def distribution_partnerships_shared_networks
		networks = []
		self.distribution_partnerships_as_partner.each do |x|
			networks = networks + x.entity.networks.where(:network_type => 2)
		end
		return networks
	end

#############################
# Production Partnerships #
#############################
	def production_partnerships_as_partner
		# Where current user is partner
		self.entity_partnerships_as_partner.where(:production_partnership => 1)

	end
	def production_partnerships_as_entity
		# Where current user is entity
		self.entity_partnerships_as_entity.where(:production_partnership => 1)

	end
	def production_partnerships_shared_products
		products = []
		self.production_partnerships_as_partner.each do |x|
			products = products + x.entity.products
		end
		return products
	end

#############################
# Products 					#
#############################
	def production_products	
		products = self.products + self.production_partnerships_shared_products
	end




###########################
# Entity Networks by Type #
###########################
	def production_networks
		self.networks.where(:network_type => 1)
	end

	def distribution_networks
		self.networks.where(:network_type => 2)
	end

	def market_networks
		self.networks.where(:network_type => 3)
	end



	def asset_activity_facts		
		AssetActivityFact.any_of({:location_network.in => self.networks.map{|x| x}},{:product.in => self.entity_products },{:entity => self })
	end

	def entity_products
		return self.products.map{|x| x}
	end

	def partner_networks
		networks = []
		self.network_memberships.each do |x|
		  networks.push(x.network)
		end
		return networks
	end

	def visible_networks
		networks = []
		networks = networks + self.networks        
		networks = networks + self.partner_networks
		return networks
	end
end
