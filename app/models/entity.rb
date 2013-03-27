class Entity
  include Mongoid::Document
  include Mongoid::Timestamps  
	field :record_status, type: Integer, default: 1
	
	has_many :users
	has_many :locations	
	has_many :products
	has_many :networks
	has_many :assets
	has_many :network_memberships
	has_many :skus
	has_many :prices

	has_many :network_facts, :inverse_of => :report_entity
	
	has_many :distribution_partnerships #, :inverse_of => :partner
#	has_many :distribution_partnerships, :inverse_of => :entity

	has_many :production_partnerships #, :inverse_of => :partner
#	has_many :production_partnerships_as_partner, :inverse_of => :entity


#	has_many :distribution_partnerships_as_entity, :class_name => 'Distribution', :inverse_of => :partner	
#	has_many :entity_partnerships_as_entity, :class_name => 'EntityPartnership', :inverse_of => :entity	

#	has_many :entity_partnerships_as_partner, :class_name => 'EntityPartnership', :inverse_of => :partner
#	has_many :entity_partnerships_as_entity, :class_name => 'EntityPartnership', :inverse_of => :entity	

	has_many :invoices
	has_many :invoice_line_items
	belongs_to :admin_user, :class_name => 'User', :inverse_of => :user

#	has_many :entity_partnerships_as_entity, as: :entity_partnerships_as_entity
#	has_one :network

# Fields
	field :admin_user_email, type: String    

	field :payment_token, type: String
	field :card_ending, type: Integer

	field :description, type: String    
	field :name, type: String
	field :address_1, type: String
	field :address_2, type: String
	
	field :city, type: String
	field :state, type: String
	field :zip, type: String


# Entity Types
#	field :distributor, type: Integer, :default => 0
#	field :brewery, type: Integer, :default => 0
#	field :lease, type: Integer, :default => 0
#	field :account, type: Integer, :default => 0

# Entity Mode
	# 0 = Deactivated, 1 = Activated Brewery, 2 = Automated Brewery, 3 = Activated Distributor, 4 = Auto Distributor
	field :mode, type: Integer, :default => 0

	field :distribution_network_count, type: Integer, :default => 0
	field :production_network_count, type: Integer, :default => 0
	field :market_network_count, type: Integer, :default => 0

##################
# Class Methods  #
##################
	def self.distribution_entities
		# Entities /w at least 1 distribution network
		 return Network.where(:network_type => 2).asc(:description).group_by{|x| x.entity}.map{|x| x[0]}	
	end
	def self.production_entities	
		return Network.where(:network_type => 1).asc(:description).group_by{|x| x.entity}.map{|x| x[0]}	
	end

#############################
# Partnerships 				#
#############################
	def related_entities
		related_entities = []

		related_entities = related_entities + self.production_partnerships.map{|x| x.partner }
		related_entities = related_entities + self.distribution_partnerships.map{|x| x.partner }
		return related_entities.uniq
	end
	
#############################
# Distribution Partnerships #
#############################
#	def distribution_partnerships_as_partner
		# Where current user is partner
#		self.entity_partnerships_as_partner.where(:distribution_partnership => 1).asc(:description)

#	end
#	def distribution_partnerships_as_entity
		# Where current user is entity
#		self.entity_partnerships_as_entity.where(:distribution_partnership => 1).asc(:description)

#	end
	def distribution_partnerships_shared_networks
		networks = []
		self.distribution_partnerships.each do |x|
			networks = networks + x.partner.networks.where(:network_type => 2)
		end
		return networks
	end

#############################
# Production Partnerships #
#############################
#	def production_partnerships_as_partner
		# Where current user is partner
#		self.entity_partnerships_as_partner.where(:production_partnership => 1)
#	end
#	def production_partnerships_as_entity
		# Where current user is entity
#		self.entity_partnerships_as_entity.where(:production_partnership => 1)
#	end

	def production_partnerships_shared_products
		products = []
		partnerships = ProductionPartnership.where(partner_id: self._id)
		partnerships.each do |x|
			products = products + x.entity.products
		end
		return products
	end	

	def production_partnerships_shared_networks
		networks = []
		self.production_partnerships.each do |x|
			networks = networks + x.partner.networks.where(:network_type => 1)
		end
		return networks
	end

#############################
# Products 					#
#############################
	def production_products	
		Product.any_of(
			{ entity: self }, 	# Products I own
			{ :_id.in => self.production_partnerships_shared_products.map{|x| x._id} },
		)
	end

#############################
# Assets 					#
#############################
	def visible_assets
		# A product I produce, a keg I own, or a network I controll		
		Asset.any_of( 
				{ :location_network.in => self.networks.map{|x| x._id} },
			  	{ :product.in => self.production_products.map{|x| x._id} }, 
			  	{ :entity => self }
		   	)
	end

	def visible_asset_activity_facts
		AssetActivityFact.any_of( 
				{ :location_network.in => self.networks.map{|x| x._id} },
			  	{ :product.in => self.production_products.map{|x| x._id} },
			  	{ :entity => self }
		   	).desc(:fact_time)
	end

	def visible_fill_activity_facts
		print 'visible_fill_activity_facts - DEPREICATED FUNCTION'
#		self.visible_asset_activity_facts.where(:handle_code => 4).desc(:fact_time) #.to_a.shift
	end

	def visible_asset_cycle_facts
		AssetCycleFact.any_of( 
			{ :cycle_networks.in => self.networks.map{|x| x._id} },
			{ :product.in => self.production_products.map{|x| x._id} },
			{ :entity => self }
		).desc(:start_time)
	end

###########################
# Entity Networks by Type #
###########################
	def production_networks
		networks = self.production_partnerships_shared_networks + self.networks.where(:network_type => 1)
	end

	def distribution_networks
		networks = distribution_partnerships_shared_networks + self.networks.where(:network_type => 2)
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

	def visible_networks
		networks = []
		networks = networks + self.networks
		networks = networks + self.distribution_partnerships_shared_networks
		networks = networks + self.production_partnerships_shared_networks		
		return networks
	end
###########################
# Locations				  #
###########################
	def visible_locations
		Location.any_of(
			{ entity_id: self._id	},
			{ :network_id.in => self.distribution_partnerships_shared_networks, location_type: 5 }		
		)
	end        


###########################
# Entity Reports		  #
###########################
	def network_score_card
		
	end
	def visible_invoices
		Invoice.where(entity: self)
	end
	def visible_invoice_attached_assets
		InvoiceAttachedAsset.where(:invoice_id.in => self.visible_invoices.map{|x| x._id})
	end
	def visible_invoice_line_items
		InvoiceLineItem.where(:invoice_id.in => self.visible_invoices.map{|x| x._id})
	end

###########################
# Entity Reports		  #
###########################
  before_save :sync_descriptions  
  def sync_descriptions
  	self.admin_user_email = self.admin_user.email rescue nil	

	self.production_network_count = self.networks.where(:network_type => 1).count
	self.distribution_network_count = self.networks.where(:network_type => 2).count
	self.market_network_count = self.networks.where(:network_type => 3).count
  end


  after_create :on_create  
  def on_create
  	if self.mode == 4
          Network.create(
            :description => self.description.to_s + " Network",
            :network_type => 2,
            :entity => self,
          )
    end
  end
end
