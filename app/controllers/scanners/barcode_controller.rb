class Scanners::BarcodeController < ApplicationController
	before_filter :authenticate_user!
	layout "web_app"

  def index	
#  	["T1",2,1,"we0ws","RF"]
    respond_to do |format|
      format.html 
      format.json {
        response = {}

        response[:toggle_options] = {}
        response[:handle_codes_auto_mode_on] = []
        response[:handle_codes_auto_mode_off] = []                    
        
        # Scanner 
        if current_user.operation > 0 && current_user.entity.keg_tracker == 1
          response[:handle_codes_auto_mode_on].push({:html => 'Move/Deliver/Pickup', :value => 5})
          response[:handle_codes_auto_mode_off].push({:html => 'Deliver', :value => 1})
          response[:handle_codes_auto_mode_off].push({:html => 'Pickup', :value => 2})
          response[:handle_codes_auto_mode_off].push({:html => 'Move', :value => 5})

          response[:handle_codes_auto_mode_on].push({:html => 'Fill', :value => 4})
          response[:handle_codes_auto_mode_off].push({:html => 'Fill', :value => 4})            
        
          response[:toggle_options][:asset_type] = 1
          response[:handle_codes_auto_mode_off].push({:html => 'Add', :value => 4})            
        end

        response[:handle_codes_auto_mode_on].push({:html => 'Register', :value => 3})
        response[:handle_codes_auto_mode_off].push({:html => 'Register', :value => 3})
        
        user_networks = current_user.entity.networks
        partner_networks = []
        if current_user.entity.keg_tracker == 1
          partner_networks = current_user.entity.distribution_partnerships_shared_networks        
        end
        all_networks = user_networks + partner_networks      
        response[:location_networks] = JqxConverter.jqxDropDownList(all_networks)
        
        response[:locations_by_network] = {}
        user_networks.each do |x|
          response[:locations_by_network][x._id] = JqxConverter.jqxDropDownList(x.locations)
        end
        partner_networks.each do |x|
          response[:locations_by_network][x._id] = JqxConverter.jqxDropDownList(x.locations.where(:location_type => 5))
        end
        
        response[:asset_types] = JqxConverter.jqxDropDownList(AssetType.all)

        response[:products] = JqxConverter.jqxDropDownList(current_user.entity.production_products)        
        render json: response
      }
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
            invoice_details = JqxConverter.jqxGrid(invoice.invoice_line_items)          

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
