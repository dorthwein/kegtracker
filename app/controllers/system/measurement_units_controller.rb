class System::MeasurementUnitsController < System::ApplicationController
	before_filter :authenticate_user!
	load_and_authorize_resource
  layout "web_app"

  # GET /measurement_units
  # GET /measurement_units.json
  def index
    @measurement_units = MeasurementUnit.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @measurement_units }
    end
  end

  # GET /measurement_units/1
  # GET /measurement_units/1.json
  def show
    @measurement_unit = MeasurementUnit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @measurement_unit }
    end
  end

  # GET /measurement_units/new
  # GET /measurement_units/new.json
  def new
    @measurement_unit = MeasurementUnit.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @measurement_unit }
    end
  end

  # GET /measurement_units/1/edit
  def edit
    @measurement_unit = MeasurementUnit.find(params[:id])
  end

  # POST /measurement_units
  # POST /measurement_units.json
  def create
    @measurement_unit = MeasurementUnit.new(params[:measurement_unit])

    respond_to do |format|
      if @measurement_unit.save
        format.html { redirect_to system_measurement_units_path, notice: 'Handle code was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /measurement_units/1
  # PUT /measurement_units/1.json
  def update
    @measurement_unit = MeasurementUnit.find(params[:id])

    respond_to do |format|
      if @measurement_unit.update_attributes(params[:measurement_unit])
        format.html { redirect_to system_measurement_units_path, notice: 'Handle code was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @measurement_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /measurement_units/1
  # DELETE /measurement_units/1.json
  def destroy
    @measurement_unit = MeasurementUnit.find(params[:id])
    @measurement_unit.destroy

    respond_to do |format|
      format.html { redirect_to measurement_units_url }
      format.json { head :no_content }
    end
  end
end
