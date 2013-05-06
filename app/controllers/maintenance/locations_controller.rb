class Maintenance::LocationsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /locations
  # GET /locations.json
  def index    		
    respond_to do |format|
      format.html # index.html.erb
      format.json {                 
          locations = JqxConverter.jqxGrid(current_user.entity.locations.where(record_status: 1))
          render json: locations
      }
    end
  end

  # GET /locations/1
  # GET /locations/1.json
  def show
    @record = Location.find(params[:id])
    @networks = current_user.entity.networks
    @location_types = Location.location_types    

    respond_to do |format|
      if can? :update, @record 
        format.html {redirect_to :action => 'edit'}
      else           
        format.html {render :layout => 'popup'}      
        format.json {                
          response = {}
          render json: response 
        }
      end
    end
  end

  # GET /locations/new
  # GET /locations/new.json
  def new
    @record = Location.new
    @networks = current_user.entity.networks
    @location_types = Location.location_types

    respond_to do |format|
      format.html {render :layout => 'popup'}      
      format.json {          
        response = {}
        render json: response 
      }
    end
  end

  # GET /locations/1/edit
  def edit    
    @record = Location.find(params[:id])
    @networks = current_user.entity.networks
    @location_types = Location.location_types    
    
      respond_to do |format|
        format.html {render :layout => 'popup'}
        format.json { 
          response = {}
          response[:jqxDropDownLists] = {}        
          render json: response 
        }        
    end
  end

  # POST /locations
  # POST /locations.json
  def create
    @record = Location.new(params[:location]) 
    @record.entity_id = current_user.entity._id

    @record.save!
    respond_to do |format|
        format.html { head :no_content }
        format.json {  render json: {} }
    end
  end

  # PUT /locations/1
  # PUT /locations/1.json
  def update
    @record = Location.find(params[:id])
    @record.update_attributes(params[:location])    
    respond_to do |format|
#      format.html
      format.json {
        render json: {}
      }
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.json  
  def destroy
    @record = Location.find(params[:id])
    @record.trash
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def restore_multiple
    respond_to do |format|    
      @records = Location.where(:id.in => params[:ids])      
      @records.restore
      format.json { 
        render json: @records
      }
    end
  end

  def delete_multiple
    respond_to do |format|    
      @records = Location.where(:id.in => params[:ids])      
      @records.trash
      format.json { 
        render json: @records
      }
    end
  end
end
