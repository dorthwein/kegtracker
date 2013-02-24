class AccountController < ApplicationController
	def index
		if !params[:token].nil?
			token = params[:token]			
			payment_method = SpreedlyCore::PaymentMethod.find(token) # Not Working...


			if payment_method.valid?
				payment_method.retain # Keep This
				current_user.entity.payment_token = token
				current_user.entity.save!			

				# Move This
				purchase_transaction = payment_method.purchase(550)
				print purchase_transaction.succeeded? # true
			 	print 'fuck'
			else
			  print "Woops!\n" + payment_method.errors.join("\n")
			end
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
