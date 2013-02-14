class Maintenance::LocationsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /locations
  # GET /locations.json

  def index    		
    respond_to do |format|
      format.html # index.html.erb
      format.json {                 
          locations = JqxConverter.jqxGrid(current_user.entity.locations)
          render json: locations
      }
    end

  end

  # GET /locations/1
  # GET /locations/1.json
  def show
    respond_to do |format|
      format.json { 
        location = Location.find(params[:id])
        networks = JqxConverter.jqxDropDownList(current_user.entity.networks)
        location_types = JqxConverter.jqxDropDownList(Location.location_types)

        response = {:location => location, :networks => networks, :location_types => location_types }

        render json: response 
      }
    end
  end

  # GET /locations/new
  # GET /locations/new.json
  def new
    respond_to do |format|
      format.json { 
        networks = JqxConverter.jqxDropDownList(current_user.entity.networks)        
        location_types = JqxConverter.jqxDropDownList(Location.location_types)        
        
        response = {:networks => networks, :location_types => location_types }
        render json: response 
      }
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
        location = Location.new(params[:location])
        
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
        if location.update_attributes(params[:location])
          render json: location
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
