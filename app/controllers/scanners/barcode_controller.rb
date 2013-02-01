class Scanners::BarcodeController < ApplicationController
	before_filter :authenticate_user!
	
  def index	
  	gather = Gatherer.new current_user.entity
	@handle_codes = HandleCode.where(:scanner => true).map { |handle_code| [handle_code.description, handle_code.id, {'data-code' => handle_code.code}] }	    

	@locations = gather.get_locations.map { |location| [location.description, location.id] }	    

	@asset_types = AssetType.all.map { |asset_type| [asset_type.description, asset_type.id] }	    

	@products = gather.get_production_products.map { |product| [product.description + ' (' + product.entity.description + ')' , product.id] }	    

#  	["T1",2,1,"we0ws","RF"]
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
# Scan Processing  
  def scan  
#    scans = JSON.parse(params[:scan])		    
	scans_array = Array.new
	scans_array.push(params[:scan])

#	scan_drone = ScanDrone.new scans_array
  scan = Asset.process_scans({:scans => scans_array})
  scan_snapshot = []  
  scan_snapshot.push(scan)
  	
    respond_to do |format|
		    format.json { render :json => scan_snapshot} #scan_drone.processed_scans }
    end
  end

# Scan Table 
=begin
  def scanTable
  	data = Hash.new
  	data.merge!(:scans => Scan.new)
	   respond_to do |format|
		    format.json { render json: data }
	   end  	
  end
=end
end
