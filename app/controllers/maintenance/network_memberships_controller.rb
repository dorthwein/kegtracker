class Maintenance::NetworkMembershipsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  # GET /network_memberships
  # GET /network_memberships.json
  def index
	 gatherer = Gatherer.new current_user.entity
	 @response = gatherer.get_given_network_memberships.map { |network_membership| {	
												:network => network_membership.network.description, 
												:entity => network_membership.entity.description, 
												:asset_distribution => network_membership.asset_distribution,
												:asset_leasing => network_membership.asset_leasing, 
												:product_production => network_membership.product_production,
												:_id => network_membership._id,
                        :edit_permission => 1,
                        :delete_permission => 1
											} 
										}
	 @response = @response + gatherer.get_received_network_memberships.map { |network_membership| {
												:network => network_membership.network.description, 
												:entity => network_membership.entity.description, 
												:asset_distribution => network_membership.asset_distribution,
												:asset_leasing => network_membership.asset_leasing, 
												:product_production => network_membership.product_production,
                        :_id => network_membership._id,
                        :edit_permission => 0,
                        :delete_permission => (network_membership.entity == current_user.entity ? 1 : 0)
											}
										}

#    @network_memberships = NetworkMembership.where(:network_id => current_user.entity.network._id)    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @response }
    end
  end

  # GET /network_memberships/1
  # GET /network_memberships/1.json
  def show
#    @network_membership = NetworkMembership.find(params[:id])
#    respond_to do |format|
#      format.html # show.html.erb
#      format.json { render json: @network_membership }
#	end
	@user_networks = Array.new
	current_user.entity.networks.each do |network|
		@user_networks.push([network.description, network._id])
	end
    @network_membership = NetworkMembership.find(params[:id])
	@networks = Array.new
	@networks.push([@network_membership.entity.description, @network_membership.entity._id])
    respond_to do |format|
        format.html { render action: "edit" }
        format.json { render json: @network_membership.errors, status: :unprocessable_entity }
    end
  end

  # GET /network_memberships/new
  # GET /network_memberships/new.json
  
  def new
    
    @network_membership = NetworkMembership.new(:network => current_user.entity.networks[0])

  	gatherer = Gatherer.new current_user.entity

    @entities = Entity.all.asc(:description).map { |entity| [entity.description, entity.id]}
    @networks = gatherer.get_networks.map { |network| [network.description, network.id]}

    respond_to do |format|
	  format.html {render :layout => false}
    end
  end

  # GET /network_memberships/1/edit
  def edit  
    @network_membership = NetworkMembership.find(params[:id])
    gatherer = Gatherer.new current_user.entity

    @entities = Entity.all.asc(:description).map { |entity| [entity.description, entity.id]}
    @networks = gatherer.get_networks.map { |network| [network.description, network.id]}

    respond_to do |format|
      format.html {render :layout => false}
    end


  end

  # POST /network_memberships
  # POST /network_memberships.json
  def create
	@network_membership = NetworkMembership.new(params[:network_membership])
    if @network_membership.save
			@response = {				
						:network => @network_membership.network.description, 
						:entity => @network_membership.entity.description, 
						:asset_distribution => @network_membership.asset_distribution,
						:asset_leasing => @network_membership.asset_leasing, 
						:product_production => @network_membership.product_production,
						:_id => @network_membership._id
					}  
					
	    respond_to do |format|    
    	    format.html { redirect_to [:maintenance, :network_memberships], notice: 'Network membership was successfully created.' + @test.to_s }
        	format.json { render json: @response, status: :created }
	    end
	end
	
=begin	
	@network_membership = NetworkMembership.where(:network_id => params[:network_membership][:network_id]).where(:entity_id => params[:network_membership][:entity_id])
	if a.exists?
	# NEED TO FIGURE OUT HOW TO UPDATE PROPERLLY - ERROR IS HERE!!!
#	    @network_membership = NetworkMembership.where(:network_id => params[:network_membership][:network_id]).where(:entity_id => params[:network_membership][:entity_id]).update(params[:network_membership])	
		a.update(:product_production => params[:network_membership][:product_production], :asset_distribution => params[:network_membership][:asset_distribution] , :location_reporting => params[:network_membership][:location_reporting] )
#		@network_membership = NetworkMembership
	else
		@network_membership = NetworkMembership.new(:product_production => params[:network_membership][:product_production], :asset_distribution => params[:network_membership][:asset_distribution], :location_reporting => params[:network_membership][:location_reporting], :entity_id => params[:network_membership][:entity_id], :network_id => params[:network_membership][:network_id])		
#		@network_membership = NetworkMembership
	end	
=end 
  end

  # PUT /network_memberships/1
  # PUT /network_memberships/1.json
  def update
    @network_membership = NetworkMembership.find(params[:id])
    respond_to do |format|
      if @network_membership.update_attributes(params[:network_membership])
		@response = {	
					:network => @network_membership.network.description, 
					:entity => @network_membership.entity.description, 
					:asset_distribution => @network_membership.asset_distribution,
					:asset_leasing => @network_membership.asset_leasing, 
					:product_production => @network_membership.product_production,
					:_id => @network_membership._id
				}  
      
        format.html { redirect_to [:maintenance, :network_memberships], notice: 'Network membership was successfully updated.' }
        format.json { render json: @response }
      else
        format.html { render action: "edit" }
        format.json { render json: @network_membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /network_memberships/1
  # DELETE /network_memberships/1.json
  def destroy
    @network_membership = NetworkMembership.find(params[:id])
    @network_membership.destroy

    respond_to do |format|
      format.html { redirect_to network_memberships_url }
      format.json { head :no_content }
    end
  end

  def new_distributor_partnership
    # Uses Form - simular to "New"

    @network_membership = NetworkMembership.new(:network => current_user.entity.networks[0])
    gatherer = Gatherer.new current_user.entity
    #  filters[key].map! { |x| x == "nil" ? nil : x }

    @entities = [Entity.find(current_user.entity)].map {|entity| [entity.description, entity.id]}
    
    @networks = []
    Entity.where(:distributor => 1).gt(:mode => 0).asc(:description).each do |entity| 
      a = entity.networks.map { |network| entity.mode == 2 ? [network.description + " (#{entity.description})", network.id] : [network.description + " (#{entity.description})" + ' - Distributor must enable partnership', network.id, :disabled => true] }
      @networks = @networks + a
    end
      # map { |entity| entity.mode == 2 ? [entity.description, entity.id] : [entity.description + ' - Distributor must enable partnership', entity.id, :disabled => true] }
    # @networks = gatherer.get_networks.map { |network| [network.description, network.id]}

    respond_to do |format|
      format.html {render :layout => false}
    end
  end
end

