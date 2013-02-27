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
      format.html {render :layout => 'popup'}
      format.json { 
        
        record = User.find(params[:id])        
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record              
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])


        render json: response 
      }
    end    
  end

  # GET /users/new
  # GET /users/new.json
  def new
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        
        record = User.new
        response = {}
        response[:jqxDropDownLists] = {}                
        response[:record] = record              
        response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])        

        render json: response 
      }
    end    
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create      
    record = User.new(params[:record])
    respond_to do |format|
      if record.save
        format.html 
        format.json {  render json: {} }
      else
        format.html { render action: "new" }
        format.json {  render json: {} }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update        
    respond_to do |format|
 		format.json { 		
			if params[:record][:password].blank?
				params[:record].delete(:password)
				params[:record].delete(:password_confirmation)
			end
			record = User.find(params[:id])			
			if record.update_attributes(params[:record])		
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
    user = User.find(params[:id])
    user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
end
