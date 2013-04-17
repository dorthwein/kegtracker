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
				current_user.entity.billing_status = 1
				current_user.entity.save!
			else
			  @error =  "Woops!\n" + payment_method.errors.join("\n")
			end
		end						

		respond_to do |format|	
        	format.html
    	end
	end

	def keg_tracker_activation
		respond_to do |format| 
			format.json {
				current_user.entity.update_attribute(:keg_tracker, params['activation'].to_i)
				render json: {:keg_tracker => current_user.entity.keg_tracker}
			}
		end

	end
	
	def pay
		token = current_user.entity.payment_token
		payment_method = SpreedlyCore::PaymentMethod.find(token)
		#print payment_method.to_json
		print payment_method.to_json + 'fuck'
		respond_to do |format|          
			format.json {
#				purchase_transaction = payment_method.purchase(550, {:gateway_token => ENV['SPREEDLYCORE_API_GATEWAY_TOKEN']})

#				purchase_transaction.succeeded? # true
				render json: payment_method

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
