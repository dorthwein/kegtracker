class Reports::InvoiceController < ApplicationController
	layout "web_app"
	def lookup
		respond_to do |format|
			format.html 
	        format.json {  
	          if !params[:invoice].nil?            
	            invoice = Invoice.find_or_create_by(:invoice_entity => current_user.entity, :number => params[:invoice][:number].to_s)        
	            invoice_details = JqxConverter.jqxGrid(invoice.invoice_details)          
	            
	            render json: {:invoice => invoice, :invoice_details => invoice_details}
	          else
	            render json: {:invoice => nil}
	          end          
	        }
	    end
	end	
end
