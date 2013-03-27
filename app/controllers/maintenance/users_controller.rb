class Maintenance::UsersController < ApplicationController
  before_filter :authenticate_user!
  layout "web_app"
  load_and_authorize_resource

  # GET /users
  # GET /users.json
  def index
#	redirect_to maintenance_users_path
    respond_to do |format|
   		format.html # index.html.erb
    	format.json { 	
      if current_user.system_admin == 1 
			   users = JqxConverter.jqxGrid(User.all)
      else
        users = JqxConverter.jqxGrid(current_user.entity.users)
      end
      		render json: users 
	    }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    respond_to do |format|
        record = User.find(params[:id])
        if can? :update, record 
          format.html {redirect_to :action => 'edit'}
        else       
          format.html {render :layout => 'popup'}
          format.json {                         
            response = {}
            response[:jqxDropDownLists] = {}        
            response[:record] = record
            if current_user.system_admin == 1 
              response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList(Entity.all)
            else
              response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])
            end
            response[:jqxDropDownLists][:account] = JqxConverter.jqxDropDownList(User.get_permission_options)
            response[:jqxDropDownLists][:operation] = JqxConverter.jqxDropDownList(User.get_permission_options)
            response[:jqxDropDownLists][:financial] = JqxConverter.jqxDropDownList(User.get_permission_options)
            render json: response 
          }
      end      
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
        if current_user.system_admin == 1 
          response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList(Entity.all)
        else
          response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])
        end
        response[:jqxDropDownLists][:operation] = JqxConverter.jqxDropDownList(User.get_permission_options)
        response[:jqxDropDownLists][:account] = JqxConverter.jqxDropDownList(User.get_permission_options)
        response[:jqxDropDownLists][:financial] = JqxConverter.jqxDropDownList(User.get_permission_options)

        render json: response 
      }
    end    
  end

  # GET /users/1/edit
  def edit
    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json { 
        record = User.find(params[:id])
        response = {}
        response[:jqxDropDownLists] = {}        
        response[:record] = record              
        
        if current_user.system_admin == 1 
          response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList(Entity.all)
        else
          response[:jqxDropDownLists][:entity_id] = JqxConverter.jqxDropDownList([current_user.entity])
        end
        response[:jqxDropDownLists][:operation] = JqxConverter.jqxDropDownList(User.get_permission_options)
        response[:jqxDropDownLists][:account] = JqxConverter.jqxDropDownList(User.get_permission_options)
        response[:jqxDropDownLists][:financial] = JqxConverter.jqxDropDownList(User.get_permission_options)

        render json: response 
      }        
    end
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
