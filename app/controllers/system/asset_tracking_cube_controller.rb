class System::AssetTrackingCubeController < ApplicationController
	before_filter :authenticate_user!
	load_and_authorize_resource

  # GET /asset_tracking_cubes
  # GET /asset_tracking_cubes.json
  def index
    @asset_tracking_cubes = AssetTrackingCube.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @asset_tracking_cubes }
    end
  end

  # GET /asset_tracking_cubes/1
  # GET /asset_tracking_cubes/1.json
  def show
    @asset_tracking_cube = AssetTrackingCube.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @asset_tracking_cube }
    end
  end

  # GET /asset_tracking_cubes/new
  # GET /asset_tracking_cubes/new.json
  def new
    @asset_tracking_cube = AssetTrackingCube.new
#	@networks = get_networks.map { |network| [(!network.description.nil? ? network.description : network.entity.description), network.id] }	    
#	@measurement_units = MeasurementUnit.all.map { |measurement_unit| [(!measurement_unit.description.nil? ? measurement_unit.description : measurement_unit.description), measurement_unit.id] }	    
	@measurement_units = MeasurementUnit.all.map { |measurement_unit| [measurement_unit.description, measurement_unit.id] }
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @asset_tracking_cube }
    end
  end

  # GET /asset_tracking_cubes/1/edit
  def edit
    @asset_tracking_cube = AssetTrackingCube.find(params[:id])
	@measurement_units = MeasurementUnit.all.map { |measurement_unit| [(!measurement_unit.description.nil? ? measurement_unit.description : measurement_unit.description), measurement_unit.id] }	    
  end

  # POST /asset_tracking_cubes
  # POST /asset_tracking_cubes.json
  def create
    @asset_tracking_cube = AssetTrackingCube.new(params[:asset_tracking_cube])
    respond_to do |format|
      if @asset_tracking_cube.save
        format.html { redirect_to system_asset_tracking_cubes_path, notice: 'Asset type was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /asset_tracking_cubes/1
  # PUT /asset_tracking_cubes/1.json
  def update
    @asset_tracking_cube = AssetTrackingCube.find(params[:id])
    respond_to do |format|
      if @asset_tracking_cube.update_attributes(params[:asset_tracking_cube])
        format.html { redirect_to system_asset_tracking_cubes_path, notice: 'Asset type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @asset_tracking_cube.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /asset_tracking_cubes/1
  # DELETE /asset_tracking_cubes/1.json
  def destroy
    @asset_tracking_cube = AssetTrackingCube.find(params[:id])
    @asset_tracking_cube.destroy

    respond_to do |format|
      format.html { redirect_to asset_tracking_cubes_url }
      format.json { head :no_content }
    end
  end
end

