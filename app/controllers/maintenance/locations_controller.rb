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
      format.html {render :layout => 'popup'}      
      format.json {          
        
        record = Location.find(params[:id])        
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record              
        response[:jqxDropDownLists][:network_id] = JqxConverter.jqxDropDownList(current_user.entity.networks)
        response[:jqxDropDownLists][:location_type] = location_types = JqxConverter.jqxDropDownList(Location.location_types)

        render json: response 
      }
    end
  end

  # GET /locations/new
  # GET /locations/new.json
  def new
    respond_to do |format|
      format.html {render :layout => 'popup'}      
      format.json {          
        
        record = Location.new
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record              
        response[:jqxDropDownLists][:network_id] = JqxConverter.jqxDropDownList(current_user.entity.networks)
        response[:jqxDropDownLists][:location_type] = location_types = JqxConverter.jqxDropDownList(Location.location_types)

        render json: response 
      }
    end
  end

  # GET /locations/1/edit
  def edit
    record = Location.find(params[:id])
    respond_to do |format|
      if can? :update, record
        format.html {render :layout => 'popup'}
        format.json { 
          response = {}
          response[:jqxDropDownLists] = {}        
          response[:record] = record              
          response[:jqxDropDownLists][:network_id] = JqxConverter.jqxDropDownList(current_user.entity.networks)
          response[:jqxDropDownLists][:location_type] = location_types = JqxConverter.jqxDropDownList(Location.location_types)

          render json: response 
        }        
      else
        format.html {redirect_to :action => 'show'}
      end
    end
  end

  # POST /locations
  # POST /locations.json
  def create
    record = Location.new(params[:record])
    respond_to do |format|
      if record.save
        format.html 
        format.json {  render json: {} }
      else
        format.html { render action: "new" }
        format.json {  render json: {} }
      end
    end
  end

  # PUT /locations/1
  # PUT /locations/1.json
  def update    
    record = Location.find(params[:id])
    record.update_attributes(params[:record])
    
    respond_to do |format|
      format.html
      format.json {
        render json: {}
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
