class System::AssetStatesController < ApplicationController
	before_filter :authenticate_user!
	load_and_authorize_resource
  layout "web_app"

  # GET /asset_states
  # GET /asset_states.json
  def index
    @asset_states = AssetState.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @asset_states }
    end
  end

  # GET /asset_states/1
  # GET /asset_states/1.json
  def show
    @asset_state = AssetState.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @asset_state }
    end
  end

  # GET /asset_states/new
  # GET /asset_states/new.json
  def new
    @asset_state = AssetState.new
#	@networks = get_networks.map { |network| [(!network.description.nil? ? network.description : network.entity.description), network.id] }	    
#	@measurement_units = MeasurementUnit.all.map { |measurement_unit| [(!measurement_unit.description.nil? ? measurement_unit.description : measurement_unit.description), measurement_unit.id] }	    
	@measurement_units = MeasurementUnit.all.map { |measurement_unit| [measurement_unit.description, measurement_unit.id] }
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @asset_state }
    end
  end

  # GET /asset_states/1/edit
  def edit
    @asset_state = AssetState.find(params[:id])
	@measurement_units = MeasurementUnit.all.map { |measurement_unit| [(!measurement_unit.description.nil? ? measurement_unit.description : measurement_unit.description), measurement_unit.id] }	    
  end

  # POST /asset_states
  # POST /asset_states.json
  def create
    @asset_state = AssetState.new(params[:asset_state])
    respond_to do |format|
      if @asset_state.save
        format.html { redirect_to system_asset_states_path, notice: 'Asset type was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /asset_states/1
  # PUT /asset_states/1.json
  def update
    @asset_state = AssetState.find(params[:id])
    respond_to do |format|
      if @asset_state.update_attributes(params[:asset_state])
        format.html { redirect_to system_asset_states_path, notice: 'Asset type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @asset_state.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /asset_states/1
  # DELETE /asset_states/1.json
  def destroy
    @asset_state = AssetState.find(params[:id])
    @asset_state.destroy

    respond_to do |format|
      format.html { redirect_to asset_states_url }
      format.json { head :no_content }
    end
  end
end
