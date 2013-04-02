class Ability
  include CanCan::Ability
  def initialize(user)

#CUSTOMER PERMISSIONS

	# Scanner Permissions
#	can [:update, :create], Asset,
	
#	User Permissions
#	can [:read], User if user.user_maintenance == 1
#	can [:read, :update, :create, :destroy] User if user.user_maintenance == 2
	
	# Scanning										

	# :read, :create, :update, :destroy, and :manage

# Operations Permissions
	# Operations
		# Location		
		# Partnerships	
		# SKUs
		# Networks
		# Products
		# Scanner		
		
 	if user.operation == 1 || user.operation == 2 || user.operation == 3
		can [:read], Location, entity_id: user.entity_id
		can [:read], Location, :network_id.in => user.entity.distribution_partnerships_shared_networks.map{|x| x._id}, location_type: 5

		can [:read], Asset, :product_id => user.entity.production_products.map{|x| x._id}		# Visible Products
		can [:read], Asset, :location_network_id.in => user.entity.networks.map{|x| x._id}		#  Networks I controll
		can [:read], Asset, :entity_id => user.entity_id 	# Assets I own

		can [:read], AssetCycleFact, :product_id => user.entity.production_products		# Visible Products
		can [:read], AssetCycleFact, :location_network_id.in => user.entity.networks.map{|x| x._id}		#  Networks I controll
		can [:read], AssetCycleFact, :entity_id => user.entity_id 	# Assets I own

		can [:read], AssetActivityFact, :product_id => user.entity.production_products		# Visible Products
		can [:read], AssetActivityFact, :location_network_id.in => user.entity.networks.map{|x| x._id}		#  Networks I controll
		can [:read], AssetActivityFact, :entity_id => user.entity_id 	# Assets I own

		can [:read], Network, :entity_id => user.entity_id
		can [:read], Product, :_id => user.entity.production_products.map{|x| x._id}
		can [:read], Scanner
		can [:read], Sku, :product_id => user.entity.production_products.map{|x| x._id}

		# Viewing in Operations, Creation/Editing in Financial
#		can [:read], Price, TBI
		can [:read], Invoice, :entity_id => user.entity_id
		can [:read], InvoiceAttachedAsset, :_id => user.entity.visible_invoice_attached_assets.map{|x| x._id}
		can [:read], InvoiceLineItem, :_id => user.entity.visible_invoice_line_items.map{|x| x._id}
	end

	if user.operation == 2 || user.operation == 3
		can [:create], Location #, location: user.entity.visible_locations
		can [:create], Asset #, asset: user.entity.visible_assets
		can [:create], AssetCycleFact #, asset_cycle_fact: user.entity.visible_asset_cycle_facts				
		can [:create], Network #, network: user.entity.visible_networks
		can [:create], Product #, product: user.entity.production_products
		can [:create], Sku #, product: user.entity.production_products
	end
	
	if user.operation == 3
		can [:update, :destroy], Location, entity_id: user.entity_id
		can [:update, :destroy], Location, :network_id.in => user.entity.distribution_partnerships_shared_networks.map{|x| x._id}, location_type: 5

		can [:update, :destroy], Asset, :product_id => user.entity.production_products.map{|x| x._id}		# Visible Products
		can [:update, :destroy], Asset, :location_network_id.in => user.entity.networks.map{|x| x._id}		#  Networks I controll
		can [:update, :destroy], Asset, :entity_id => user.entity_id 	# Assets I own

		can [:update, :destroy], Network, :entity_id => user.entity_id 
		can [:update, :destroy], Product, :_id => user.entity.production_products.map{|x| x._id}
		can [:update, :destroy], Sku, :product_id => user.entity.production_products.map{|x| x._id}
	end



# Account Admin
	# Admin
		# Users
		# Entity
	if user.account == 1 || user.account == 2 || user.account == 3
		can [:read], User, :entity_id => user.entity_id
	end
	if user.account == 2 || user.account == 3
		can [:create], User
	end
	if user.account == 3
		can [:update, :destroy], User, :entity_id => user.entity_id
		can [:update], Entity, _id: user.entity_id
	end

# Financial Admin
	# Financial
		# Financials
		# Price
		# Invoices
	if user.financial == 1 || user.financial == 2 || user.financial == 3
		can [:read], Invoice, :_id => user.entity.visible_invoices.map{|x| x._id}
		can [:read], InvoiceAttachedAsset, :_id => user.entity.visible_invoice_attached_assets.map{|x| x._id}
		can [:read], InvoiceLineItem, :_id => user.entity.visible_invoice_line_items.map{|x| x._id}

	end
	if user.financial == 2 || user.financial == 3
		can [:create], Invoice
		can [:create], InvoiceAttachedAsset
		can [:create], InvoiceLineItem

	end
	if user.financial == 3
		can [:update, :destroy], Invoice, :_id => user.entity.visible_invoices.map{|x| x._id}
		can [:update, :destroy], InvoiceAttachedAsset, :_id => user.entity.visible_invoice_attached_assets.map{|x| x._id}
		can [:update, :destroy], InvoiceLineItem, :_id => user.entity.visible_invoice_line_items.map{|x| x._id}
	end






=begin
	if user.location_maintenance == 1 || user.scanner_delivery_pickup == 1 || user.scanner_add == 1 || user.scanner_fill == 1 || user.scanner_move == 1
		can [:view], Location
		can [:view], Network
		can [:manage], Asset
	end
	# View Product
	if user.scanner_fill == 1 || user.product_maintenance == 1 
		can [:view], Product
	end	
	# View User
	if user.user_maintenance == 1
		can [:view], User
	end
	can [:view], User, :user_id => user

	# ***************
	# Maintenance 
	# ***************	

	# Location
	if user.location_maintenance == 1
		can [:manage, :maintenance_menu], Location, :network_id => user.entity.networks.map { |network| network.id }
		can [:create], Location
		can [:view, :maintenance_menu], Network
		can [:view, :maintenance_menu], Entity		
	end

	# Products
	if user.product_maintenance == 1
		can [:manage, :maintenance_menu], Product, :entity_id => user.entity._id
	end
		
	# User
	if user.user_maintenance == 1
		can [:manage, :maintenance_menu], User, :entity_id => user.entity._id
	end
	
	# Network Membership
	if user.network_maintenance == 1
		can [:manage, :maintenance_menu], NetworkMembership, :network_id => user.entity.networks.map { |network| network.id }
		can [:create], NetworkMembership
		can [:view, :maintenance_menu], Entity
		can [:view, :maintenance_menu], Network
		
		can [:manage, :maintenance_menu], Network, :_id => user.entity.networks.map { |network| network.id }
		can [:create], Network
		can [:view, :maintenance_menu], Entity
	end
	# Production
	if user.production_maintenance == 1
#		can [:manage, :maintenance_menu], Production
	end
	# Barcodes
	if user.barcode_maker_maintenance == 1
		can [:manage, :barcode_maker_maintenance], BarcodeMaker
	end
	
	# ***************
	# System
	# ***************	
=end
	if user.system_admin == 1
		can [:system_admin, :manage], :all
	end


	# Product Maintenance
#	can [:read], Product, user.product_maintenance => 1
#	can [:read, :update, :create, :destroy], Product, :product_maintenance => 2

	# Production Maintenance		
#	can [:read] User if user.production_maintenance == 1
#	can [:read, :update, :create, :destroy] User if user.production_maintenance == 2	
	  
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

  end  
end
