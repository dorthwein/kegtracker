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
		can [:read], Asset, :product_id => user.entity.production_products.map{|x| x._id}		# Visible Products
		can [:read], Asset, :location_network_id.in => user.entity.networks.map{|x| x._id}		#  Networks I controll
		can [:read], Asset, :entity_id => user.entity_id 	# Assets I own		
		can [:sku_summary_report_simple], Asset
		if user.entity.keg_tracker == 1
			
			can [:asset_fill_to_fill_cycle_fact_by_delivery_network, :asset_fill_to_fill_cycle_fact_by_fill_network, :activity_summary_report_simple], Float


			can [:read], Location, entity_id: user.entity_id
			can [:read], Location, :network_id.in => user.entity.distribution_partnerships_shared_networks.map{|x| x._id}, location_type: 5

			can [:read], DistributionPartnership, entity_id: user.entity_id
			can [:read], ProductionPartnership, entity_id: user.entity_id


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
	end

	if user.operation == 2 || user.operation == 3
		can [:create], Asset #, asset: user.entity.visible_assets
		if user.entity.keg_tracker == 1
			can [:create], Location #, location: user.entity.visible_locations
			can [:create], AssetCycleFact #, asset_cycle_fact: user.entity.visible_asset_cycle_facts				
			can [:create], Network #, network: user.entity.visible_networks
			can [:create], Product #, product: user.entity.production_products
			can [:create], Sku #, product: user.entity.production_products

			can [:create], DistributionPartnership, entity_id: user.entity_id
			can [:create], ProductionPartnership, entity_id: user.entity_id
		end
	end

	if user.operation == 3
		can [:update, :destroy, :delete_multiple], Asset, :product_id => user.entity.production_products.map{|x| x._id}		# Visible Products
		can [:update, :destroy, :delete_multiple], Asset, :location_network_id.in => user.entity.networks.map{|x| x._id}		#  Networks I controll
		can [:update, :destroy, :delete_multiple], Asset, :entity_id => user.entity_id 	# Assets I own

		if user.entity.keg_tracker == 1
			can [:update, :destroy, :delete_multiple], Location, entity_id: user.entity_id
			can [:update, :destroy, :delete_multiple], Location, :network_id.in => user.entity.distribution_partnerships_shared_networks.map{|x| x._id}, location_type: 5

			can [:update, :destroy, :delete_multiple], DistributionPartnership, entity_id: user.entity_id
			can [:update, :destroy, :delete_multiple], ProductionPartnership, entity_id: user.entity_id

			can [:update, :destroy, :delete_multiple], Network, :entity_id => user.entity_id 
			can [:update, :destroy, :delete_multiple], Product, :_id => user.entity.production_products.map{|x| x._id}
			can [:update, :destroy, :delete_multiple], Sku, :product_id => user.entity.production_products.map{|x| x._id}
		end
	end

	

# Financial Admin
	# Financial
		# Financials
		# Price
		# Invoices
	if user.entity.keg_tracker == 1	
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
			can [:update, :destroy, :delete_multiple], Invoice, :_id => user.entity.visible_invoices.map{|x| x._id}
			can [:update, :destroy, :delete_multiple], InvoiceAttachedAsset, :_id => user.entity.visible_invoice_attached_assets.map{|x| x._id}
			can [:update, :destroy, :delete_multiple], InvoiceLineItem, :_id => user.entity.visible_invoice_line_items.map{|x| x._id}
		end
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
		can [:update, :destroy, :delete_multiple], User, :entity_id => user.entity_id
		can [:update], Entity, _id: user.entity_id
	end

	if user.system_admin == 1
		can [:distributor_upload, :system_admin, :manage], :all
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
