class AccountController < ApplicationController
	before_filter :authenticate_user!	
	layout "web_app"

	def index
		if !params[:token].nil?
			payment_token = params[:token]			
			payment_method = SpreedlyCore::PaymentMethod.find(payment_token)
			if payment_method.valid?
			  purchase_transaction = payment_method.purchase(550)
			  purchase_transaction.succeeded? # true
			else
			  flash[:notice] = "Woops!\n" + payment_method.errors.join("\n")
			end

=begin
			print payment_method.to_s
			if payment_method.valid?
				payment_method.retain # Keep This
				current_user.entity.payment_token = token
				current_user.entity.save!			

				# Move This
				purchase_transaction = payment_method.purchase(550)
				print purchase_transaction.succeeded? # true
			 	print 'IT WORKED'
			else
			  print "Woops!\n" + payment_method.errors.join("\n")
			end
=end			
		end		

		respond_to do |format|
        	format.html
    	end
	end

	def create
		respond_to do |format|          
		  format.json { 
		  	if Registration.create(params[:registration])
		  		response = {:success => true}
		  	else
		  		response = {:success => false}
		  	end
		  	render json: response
		  }        
		end	
	end
end
