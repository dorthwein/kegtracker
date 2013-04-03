class Reports::LocationsController < ApplicationController
  	before_filter :authenticate_user!
  	layout "web_app"
  	load_and_authorize_resource

	def index    
		respond_to do |format|		
		  	format.html # index.html.erb
		  	format.json { 
  				records = JqxConverter.jqxGrid(current_user.entity.visible_locations.map{|x| {
            a: x.externalID,
            b: x.description,
            c: x.network_description,
            d: x.name,
            e: x.street,
            f: x.city,
            g: x.state,
            h: x.zip,
#            i: x.location_type,
            j: x.location_type_description,
            k: x._id,
            l: current_user.entity.visible_assets.where(location_id: x._id).count,

          }})
				  render json: records
		  	}
		end
	end
  	def show
	    respond_to do |format|
	      format.html {render :layout => 'popup'}
	      format.json { 
	        
	        record = Location.find(params[:id])
	        response = {}
	        response[:jqxDropDownLists] = {}        
		   	        
	        
	        response[:record] = record              
	        response[:jqxDropDownLists][:network_id] = JqxConverter.jqxDropDownList(current_user.entity.networks)
	        response[:jqxDropDownLists][:location_type] = JqxConverter.jqxDropDownList(Location.location_types)
			response[:jqxGrid] = JqxConverter.jqxGrid(current_user.entity.visible_assets.where(location: record))

	        render json: response 
	      }
	    end    
  	end
  # GET /Locations/new
  # GET /Locations/new.json
  def new
    respond_to do |format|
        format.html {redirect_to :action => 'show'}
    end    
  end

  # GET /Locations/1/edit
  def edit
    record = Location.find(params[:id])
    respond_to do |format|
      if  1 == 0 # can? :update, record
        format.html {render :layout => 'popup'}
        format.json { 
          response = {}

          render json: response 
        }        
      else
        format.html {redirect_to :action => 'show'}
      end
    end
  end

  # POST /Locations
  # POST /Locations.json
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

  # PUT /Locations/1
  # PUT /Locations/1.json
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

  # DELETE /Locations/1
  # DELETE /Locations/1.json
  def destroy
    record = Location.find(params[:id])
    record.destroy

    respond_to do |format|    
      format.json { head :no_content }
    end
  end


end
