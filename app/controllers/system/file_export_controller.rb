class System::FileExportController < ApplicationController
  skip_before_filter :verify_authenticity_token

	def jqx_excel

	end

	def jqx_csv
	    respond_to do |format|	       
	        format.csv {              
	        	csv = params[:content]
	          send_data csv 
	        }
	      
	    end		
	end

	def google_csv

	end
end
