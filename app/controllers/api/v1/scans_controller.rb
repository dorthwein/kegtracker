=begin
class Api::V1::ScansController < ApplicationController
	skip_before_filter :verify_authenticity_token
	before_filter :authenticate_user!

  def scan  
#    scans = JSON.parse(params[:scan])		    
	print params[:scan].class
	if params[:scan].kind_of?(Array)	

		scan_drone = ScanDrone.new params[:scan]

	elsif params[:scan].kind_of?(Hash)
		scans_array = Array.new
		scans_array.push(params[:scan])	
		scan_drone = ScanDrone.new scans_array
	end

#	scan_drone.process(scans_array)
	test = {:error => 'success'}
    respond_to do |format|
      	format.json { render json: test }
    end
  end

end
=end