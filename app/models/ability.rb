class Ability
  include CanCan::Ability
  def initialize(user)
#CUSTOME PERMISSIONS

	# Scanner Permissions
#	can [:update, :create], Asset,
	
#	User Permissions
#	can [:read], User if user.user_maintenance == 1
#	can [:read, :update, :create, :destroy] User if user.user_maintenance == 2
	
	# View Location
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
	print user.entity.networks.map { |network| network.id}
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
