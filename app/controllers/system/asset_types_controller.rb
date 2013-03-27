class System::AssetTypesController < System::ApplicationController
	before_filter :authenticate_user!
	load_and_authorize_resource
  layout "web_app"

  # GET /asset_types
  # GET /asset_types.json
  def index 
    respond_to do |format|
      format.html # index.html.erb
      format.json { 
        asset_types = AssetType.all
        render json: asset_types 
      }
    end
  end

  # GET /asset_types/1
  # GET /asset_types/1.json
  def show    
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        
        record = AssetType.find(params[:id])        
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record              
        response[:jqxDropDownLists][:measurement_unit_id] = JqxConverter.jqxDropDownList(MeasurementUnit.all)

        render json: response 
      }
    end
  end

  # GET /asset_types/new
  # GET /asset_types/new.json
  def new    
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        record = AssetType.new
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record              
        response[:jqxDropDownLists][:measurement_unit_id] = JqxConverter.jqxDropDownList(MeasurementUnit.all)

        render json: response 
      }
    end
  end

  # GET /asset_types/1/edit
  def edit
  end

  # POST /asset_types
  # POST /asset_types.json
  def create
    record = AssetType.new(params[:record])
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

  # PUT /asset_types/1
  # PUT /asset_types/1.json
  def update  	
    record = AssetType.find(params[:id])
    record.update_attributes(params[:record])
    
    respond_to do |format|
      format.html
      format.json {
        render json: {}
      }
    end
  end

  # DELETE /asset_types/1
  # DELETE /asset_types/1.json
  def destroy
    asset_type = AssetType.find(params[:id])
    asset_type.destroy

    respond_to do |format|
      format.html { redirect_to asset_types_url }
      format.json { head :no_content }
    end
  end
end
