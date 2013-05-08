class Scanners::BarcodeController < ApplicationController
	before_filter :authenticate_user!
	layout "web_app"

  def index	
#  	["T1",2,1,"we0ws","RF"]
    @locations = []
    user_networks = current_user.entity.networks
    partner_networks = []

    if current_user.entity.keg_tracker == 1
      partner_networks = current_user.entity.distribution_partnerships_shared_networks        
    end
    all_networks = user_networks + partner_networks      
    user_networks.each do |x|
      #@locations.push(x.locations.map{|y| [y.description + ' - ' + x.description, y._id] })
      @locations = @locations + x.locations.map{|y| [y.description + ' (' + x.description + ')', y._id] }
    end
    partner_networks.each do |x|
      @locations = @locations + x.locations.map{|y| [y.description + ' (' + x.description + ')', y._id] }
    end
    @asset_types = AssetType.all.map{|x| [x.description, x._id] }
    @products = current_user.entity.production_products.map{|x| [x.description, x._id]}

    respond_to do |format|
      format.html 
    end
  end
  
# Scan Processing  
  def scan  
	scans_array = Array.new
	scans_array.push(params[:scan])

#  scan = Asset.process_scans({:scans => scans_array})
  scan_snapshot = Scanner.process_scans({:scans => scans_array})

#  scan_snapshot = []  
 # scan_snapshot.push(scan)  	
    respond_to do |format|
		    format.json { render json: scan_snapshot} #scan_drone.processed_scans }
    end
  end

  def scanner_options    
    respond_to do |format|
    end
  end

  def find_invoice
    respond_to do |format|
        format.json {  

          if !params[:invoice].nil?            
            invoice = Invoice.find_or_create_by(:entity => current_user.entity, :invoice_number => params[:invoice][:invoice_number].to_s)        
            invoice_details = JqxConverter.jqxGrid(invoice.invoice_line_items);

            render json: {:invoice => invoice, :invoice_details => invoice_details}
          else
            render json: {:invoice => nil}
          end          
        }
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
