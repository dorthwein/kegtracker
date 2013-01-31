class Maintenance::UsersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /users
  # GET /users.json
  def index
  
#	redirect_to maintenance_users_path
    respond_to do |format|
    	format.html # index.html.erb
    	format.json { 	
			if current_user.system_admin == 1
				users = User.all
			else
				gatherer = Gatherer.new current_user.entity
				users = gatherer.get_users
			end

			response =	users.map { |user| {
				:entity => user.entity.description,
				:first_name => user.first_name,
				:last_name => user.last_name,
				:email => user.email,
				:cell_phone => user.cell_phone,
				:office_phone => user.office_phone,
				:scanner_delivery_pickup => user.scanner_delivery_pickup,
				:scanner_add => user.scanner_add,
				:scanner_fill => user.scanner_fill,
				:scanner_move => user.scanner_move,
						
				# Maintenance Permissions - 0 => No Permissions, 1 => View, 2 => Admin
				:user_maintenance => user.user_maintenance,
				:location_maintenance => user.location_maintenance,
				:product_maintenance => user.product_maintenance,
				:production_maintenance => user.production_maintenance,
				:network_maintenance => user.network_maintenance,
				:barcode_maker_maintenance => user.barcode_maker_maintenance,
				:_id => user._id										 
				} 
			}


      	render json: response 
      }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    user = User.find(params[:id])        		
#    @permission_types = PermissionType.all

	# Grab all Authorizations
#	@authorizations = Authorization.where("user_id = ?", @user.id)	
    respond_to do |format|
    	if current_user.system_admin == 1
    		entities = Entity.all.map{|x| {:html => x.description, :value => x._id}}
    	else
			entities = [{:html => current_user.entity.description, :value => current_user.entity._id}]
    	end
    	response = {:user => user, :entities => entities }
    	format.json { 

      		render json: response 

		}
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    respond_to do |format|
    	if current_user.system_admin == 1
    		entities = Entity.all.map{|x| {:html => x.description, :value => x._id}}
    	else
			entities = [{:html => current_user.entity.description, :value => current_user.entity._id}]
    	end
    	response = {:entities => entities }
    	format.json { 
      		render json: response 
		}
    end
=begin      	
  	gatherer = Gatherer.new current_user.entity  
	@entities = gatherer.get_entities.map { |entity| [entity.description, entity.id]}
	@response = {	
					:entity => @user.entity.description,
					:first_name => @user.first_name,
					:last_name => @user.last_name,
					:email => @user.email,
					:cell_phone => @user.cell_phone,
					:office_phone => @user.office_phone,
					:scanner_delivery_pickup => @user.scanner_delivery_pickup,
					:scanner_add => @user.scanner_add,
					:scanner_fill => @user.scanner_fill,
					:scanner_move => @user.scanner_move,
							
					# Maintenance Permissions - 0 => No Permissions, 1 => View, 2 => Admin
					:user_maintenance => @user.user_maintenance,
					:location_maintenance => @user.location_maintenance,
					:product_maintenance => @user.product_maintenance,
					:production_maintenance => @user.production_maintenance,
					:network_maintenance => @user.network_maintenance,
					:barcode_maker_maintenance => @user.barcode_maker_maintenance,
					:_id => @user._id										 
			}  
    @user = User.new
    respond_to do |format|
      format.html # new.html.erb
	  format.html {render :layout => false}
    end
=end    
  end

  # GET /users/1/edit
  def edit
  	gatherer = Gatherer.new current_user.entity  
    @user = User.find(params[:id])
	@entities = gatherer.get_entities.map { |entity| [entity.description, entity.id]}
	
    respond_to do |format|
	  format.html {render :layout => false}
    end
  end

  # POST /users
  # POST /users.json
  def create      
    respond_to do |format|    			
		format.json { 
#			email = 'NEW_USER_' + Time.new().to_i.to_s + '@' + 'change_user_login' + '.com'
#			user = User.new(:entity => current_user.entity, :email => email, :password => current_user.entity.description, :password_confirmation => current_user.entity.description)
			user = User.new(params)
			
			if user.save
				render json: user
			else
				render json: {:success => false, :message => 'E-Mail already exists - please change e-mail or contact support'}
			end
		}        
=begin
      if @user.save

			@response = {	
							:entity => @user.entity.description,
							:first_name => @user.first_name,
							:last_name => @user.last_name,
							:email => @user.email,
							:cell_phone => @user.cell_phone,
							:office_phone => @user.office_phone,
							:scanner_delivery_pickup => @user.scanner_delivery_pickup,
							:scanner_add => @user.scanner_add,
							:scanner_fill => @user.scanner_fill,
							:scanner_move => @user.scanner_move,
									
							# Maintenance Permissions - 0 => No Permissions, 1 => View, 2 => Admin
							:user_maintenance => @user.user_maintenance,
							:location_maintenance => @user.location_maintenance,
							:product_maintenance => @user.product_maintenance,
							:production_maintenance => @user.production_maintenance,
							:network_maintenance => @user.network_maintenance,
							:barcode_maker_maintenance => @user.barcode_maker_maintenance,
							:_id => @user._id										 
					}        
        format.html { redirect_to maintenance_users_path, notice: 'User was successfully created.' }
        format.json { render json: @response, status: :created, user: @user }        
      else
        format.html { render action: "new" }
      end
=end      
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update        
    respond_to do |format|
 		format.json { 		
			if params[:user][:password].blank?
				params[:user].delete(:password)
				params[:user].delete(:password_confirmation)
			end
			user = User.find(params[:id])			
			if user.update_attributes(params[:user])		
	 	  		render json: {:success => true } 
	 	  	else
				render json: {:success => false, :message => 'User information invalid, please change user e-mail & password' } 
	 	  	end
 	  	}
=begin  
      if @user.update_attributes(params[:user])
			@response = {	
					:entity => @user.entity.description,
					:first_name => @user.first_name,
					:last_name => @user.last_name,
					:email => @user.email,
					:cell_phone => @user.cell_phone,
					:office_phone => @user.office_phone,
					:scanner_delivery_pickup => @user.scanner_delivery_pickup,
					:scanner_add => @user.scanner_add,
					:scanner_fill => @user.scanner_fill,
					:scanner_move => @user.scanner_move,
							
					# Maintenance Permissions - 0 => No Permissions, 1 => View, 2 => Admin
					:user_maintenance => @user.user_maintenance,
					:location_maintenance => @user.location_maintenance,
					:product_maintenance => @user.product_maintenance,
					:production_maintenance => @user.production_maintenance,
					:network_maintenance => @user.network_maintenance,
					:barcode_maker_maintenance => @user.barcode_maker_maintenance,
					:_id => @user._id										 
			}
      
#        format.html { redirect_to maintenance_users_path, notice: 'User was successfully updated.' }
		format.json { render json: @response }
      else
#        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
=end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
end
