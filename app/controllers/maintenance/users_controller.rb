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
			users = JqxConverter.jqxGrid(current_user.entity.users)
      		render json: users 
	    }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    
    respond_to do |format|
    	format.json { 
    		user = User.find(params[:id])        		
    		response = {:user => user}    		
      		render json: response 
		}
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    respond_to do |format|
    	format.json { 
      		render json: {} 
		}
    end
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create      
    respond_to do |format|
		format.json {
			user = User.new(params[:user])
			if user.save
				render json: user
			else
				render json: {:success => false, :message => 'E-Mail already exists - please change e-mail or contact support'}
			end
		}         
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
