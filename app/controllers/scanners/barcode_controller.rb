class Scanners::BarcodeController < ApplicationController
	before_filter :authenticate_user!
	layout "web_app"

  def index	
#  	["T1",2,1,"we0ws","RF"]
    @locations = []
    @locations = current_user.entity.visible_locations.map{|y| [y.description + ' (' + y.network_description + ')', y._id] }
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
    scan_snapshot = Scanner.process_scans({:scans => scans_array})
    respond_to do |format|
		    format.json { render json: scan_snapshot}
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
end
