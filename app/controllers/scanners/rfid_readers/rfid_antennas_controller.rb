=begin
class Scanners::RfidReaders::RfidAntennasController < ApplicationController
	before_filter :authenticate_user!
	load_and_authorize_resource

  def show	
#  	@apps = App.where("orders.packages.name" => "supper").all
  	@rfid_antenna = RfidAntenna.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @location }
    end
  end
  
  def edit
  	gatherer = Gatherer.new current_user.entity
  	
	@rfid_antenna = RfidAntenna.find(params[:id])
	@locations = Location.where(:network => @rfid_antenna.rfid_reader.network._id).asc(:description).map { |location| [location.description, location.id] }  	
	@products = gatherer.get_production_products.map { |product| [product.description + ' (' + product.entity.description + ')', product.id] }
  	@handle_codes_array = HandleCode.all.map { |handle_code| [handle_code.description, handle_code.id, {'data-code' => handle_code.code}] }  	
  	@asset_types = AssetType.all.map { |asset_type| [asset_type.description, asset_type.id] }  	
  end
  
  def update
  	@rfid_antenna = RfidAntenna.find(params[:id])
    respond_to do |format|
      if @rfid_antenna.update_attributes(params[:rfid_antenna])
        format.html { redirect_to scanners_rfid_readers_path, notice: 'RFID Antenna was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end
  
  def rfid_read
  	
  end
end
=end
