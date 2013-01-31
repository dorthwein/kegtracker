class System::AssetTypesController < System::ApplicationController
	before_filter :authenticate_user!
	load_and_authorize_resource

  # GET /asset_types
  # GET /asset_types.json
  def index
    @asset_types = AssetType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @asset_types }
    end
  end

  # GET /asset_types/1
  # GET /asset_types/1.json
  def show
    @asset_type = AssetType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @asset_type }
    end
  end

  # GET /asset_types/new
  # GET /asset_types/new.json
  def new
    @asset_type = AssetType.new
#	@networks = get_networks.map { |network| [(!network.description.nil? ? network.description : network.entity.description), network.id] }	    
#	@measurement_units = MeasurementUnit.all.map { |measurement_unit| [(!measurement_unit.description.nil? ? measurement_unit.description : measurement_unit.description), measurement_unit.id] }	    
	@measurement_units = MeasurementUnit.all.map { |measurement_unit| [measurement_unit.description, measurement_unit.id] }
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @asset_type }
    end
  end

  # GET /asset_types/1/edit
  def edit
    @asset_type = AssetType.find(params[:id])
	@measurement_units = MeasurementUnit.all.map { |measurement_unit| [(!measurement_unit.description.nil? ? measurement_unit.description : measurement_unit.description), measurement_unit.id] }	    
  end

  # POST /asset_types
  # POST /asset_types.json
  def create
    @asset_type = AssetType.new(params[:asset_type])
    respond_to do |format|
      if @asset_type.save
        format.html { redirect_to system_asset_types_path, notice: 'Asset type was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /asset_types/1
  # PUT /asset_types/1.json
  def update  	
    @asset_type = AssetType.find(params[:id])

    respond_to do |format|
      if @asset_type.update_attributes(params[:asset_type])
        format.html { redirect_to system_asset_types_path, notice: 'Asset type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @asset_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /asset_types/1
  # DELETE /asset_types/1.json
  def destroy
    @asset_type = AssetType.find(params[:id])
    @asset_type.destroy

    respond_to do |format|
      format.html { redirect_to asset_types_url }
      format.json { head :no_content }
    end
  end
end
