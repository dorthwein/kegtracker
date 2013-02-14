class Maintenance::RfidAntennasController < ApplicationController
=begin
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /rfids
  # GET /rfids.json
  def index
    @rfid_antennas = RfidAntenna.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rfid_antennas }
    end
  end

  # GET /rfids/1
  # GET /rfids/1.json
  def show
    @rfid_antenna = RfidAntenna.find(params[:id])
	
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @rfid_antenna }
    end
  end

  # GET /rfids/new
  # GET /rfids/new.json
  def new
    @rfid_antenna = RfidAntenna.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rfid_antenna }
    end
  end

  # GET /rfids/1/edit
  def edit
    @rfid_antenna = RfidAntenna.find(params[:id])
  end

  # POST /rfids
  # POST /rfids.json
  def create
    @rfid_antenna = RfidAntenna.create(params[:rfid_antenna])
    respond_to do |format|
      if @rfid_antenna.save
        format.html { redirect_to [:maintenance, @rfid_antenna], notice: 'Rfid was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /rfids/1
  # PUT /rfids/1.json
  def update
    @rfid_antenna = RfidAntenna.find(params[:id])
    respond_to do |format|
      if @RfidAntenna.update_attributes(params[:rfid])
        format.html { redirect_to @rfid_antenna, notice: 'Rfid was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @RfidAntenna.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rfids/1
  # DELETE /rfids/1.json
  def destroy
    @rfid_antenna = RfidAntenna.find(params[:id])
    @RfidAntenna.destroy

    respond_to do |format|
      format.html { redirect_to rfids_url }
      format.json { head :no_content }
    end
  end
  def read
  	  
  	
  end
=end
end
