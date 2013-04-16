class Account::ProfilesController < ApplicationController
	before_filter :authenticate_user!	
	layout "web_app"
	def show
		# If Token Exists - Then this is just after a save event
		if !params[:token].nil?
			if !current_user.entity.payment_token.nil?
			# Check current user for existing token
				# If current token  exists, redact token
				old_payment_method = SpreedlyCore::PaymentMethod.find(current_user.entity.payment_token)
				redact_transaction = old_payment_method.redact				
			end

			# Check if payment is valid - Authorize?
			new_payment_token = params[:token]			
			payment_method = SpreedlyCore::PaymentMethod.find(new_payment_token)
			# Store Token
			# Store card ending
			if payment_method.valid?
				#print payment_method.to_json
				payment_method.retain # Keep This				
				current_user.entity.payment_token = payment_method.token
				current_user.entity.card_ending = payment_method.last_four_digits
				current_user.entity.save!
			else
			  @error =  "Woops!\n" + payment_method.errors.join("\n")
			end
		end		

		respond_to do |format|
        	format.html
    	end
	end

	def pay
		token = current_user.entity.payment_token
		payment_method = SpreedlyCore::PaymentMethod.find(token)
		#print payment_method.to_json
		print token
		respond_to do |format|          
			format.xml {
				purchase_transaction = payment_method.purchase(550, {:gateway_token => ENV['SPREEDLYCORE_API_GATEWAY_TOKEN']})

#				purchase_transaction.succeeded? # true
				render xml: purchase_transaction

			}
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
