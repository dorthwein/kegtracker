class Maintenance::LocationsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /locations
  # GET /locations.json

  def index    		
    respond_to do |format|
      format.html # index.html.erb
      format.json { 
      		gatherer = Gatherer.new current_user.entity
    			response = gatherer.get_locations.map { |location| {
														:external_id => location.externalID,
														:description => location.description,
														:network => location.network_description,

														:name => location.name,
														:street => location.street,
														:city => location.city,
														:state => location.state,
														:zip => location.zip,

														:on_premise => location.on_premise,
														:off_premise => location.off_premise,
														:empty => location.empty,
														:inventory => location.inventory,
														:production => location.production,
														:partner_entity => location.partner_entity,
														:_id => location._id
													}
										}		    	
      		render json: response 
      	
      	}
    end

  end

  # GET /locations/1
  # GET /locations/1.json
  def show
    location = Location.find(params[:id])
    if current_user.system_admin == 1
      networks = Network.all.map{|x| {:html => x.description, :value => x._id}}
    else
      networks = current_user.entity.networks.map{|x| { :html => x.description, :value => x._id }}
    end
    response = {:location => location, :networks => networks }
    respond_to do |format|
      format.json { render json: response }
    end
  end

  # GET /locations/new
  # GET /locations/new.json
  def new
    if current_user.system_admin == 1
      networks = Network.all.map{|x| {:html => x.description, :value => x._id}}
    else
      networks = current_user.entity.networks.map{|x| { :html => x.description, :value => x._id }}
    end
    response = {:location => location, :networks => networks }
    respond_to do |format|
      format.json { render json: response }
    end
  end

  # GET /locations/1/edit
  def edit

  end

  # POST /locations
  # POST /locations.json
  def create
    respond_to do |format|          
      format.json { 
        location = Location.new(params)
        
        if location.save
          render json: location
        else
          render json: {:success => false, :message => 'Location creation error, please contact support'}
        end
      }        
    end
  end

  # PUT /locations/1
  # PUT /locations/1.json
  def update	
    respond_to do |format|
      format.json {
        location = Location.find(params[:id])
        if location.update_attributes(params)
          render json: {:sucess => true}
        else
          render json: {:sucess => false, :message => 'Location update error, please contact support'}
        end
      }
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  def destroy
    location = Location.find(params[:id])
    location.destroy

    respond_to do |format|    
      format.json { head :no_content }
    end
  end
end
