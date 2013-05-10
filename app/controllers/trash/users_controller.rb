class Trash::UsersController < ApplicationController
  before_filter :authenticate_user!  
  load_and_authorize_resource

  # GET /users
  # GET /users.json
  def index
#	redirect_to maintenance_users_path
    respond_to do |format|
   		format.html 
    	format.json { 	
      if current_user.system_admin == 1 
			   users = JqxConverter.jqxGrid(User.all)
      else
        users = JqxConverter.jqxGrid(current_user.entity.users.where(record_status: 0))
      end
      		render json: users 
	    }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    respond_to do |format|
        @record = User.find(params[:id])
        if current_user.system_admin == 1 
          @entities = Entity.all
        else
          @entities = [current_user.entity]
        end

        @user_permission_options = User.get_permission_options

        if can? :update, @record 
          format.html {redirect_to :action => 'edit'}
        else       
          format.html {render :layout => 'popup'}
          format.json {                         
            response = {}
            render json: response 
          }
      end      
    end    
  end

  # GET /users/new
  # GET /users/new.json
  def new
    respond_to do |format|
      @record = User.new
      if current_user.system_admin == 1 
        @entities = Entity.all
      else
        @entities = [current_user.entity]
      end
      @user_permission_options = User.get_permission_options

      format.html {render :layout => 'popup'}
      format.json {                 
        response = {}
        render json: response 
      }
    end    
  end

  # GET /users/1/edit
  def edit
    @record = User.find(params[:id])
    if current_user.system_admin == 1 
      @entities = Entity.all
    else
      @entities = [current_user.entity]
    end
    @user_permission_options = User.get_permission_options

    respond_to do |format|
      format.html {render :layout => 'popup'}
      format.json {         
        response = {}
        render json: response 
      }
    end
  end

  # POST /users
  # POST /users.json
  def create      
    @record = User.new(params[:user])
    @record.save!
    respond_to do |format|    
        format.html { head :no_content }
        format.json {  render json: {} }
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @record = User.find(params[:id])      
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    respond_to do |format|
 		format.json { 		
      if @record.update_attributes(params[:user])    
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
    @record = User.find(params[:id])
    @record.trash
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def restore_multiple
    respond_to do |format|    
      @records = User.where(:id.in => params[:ids])      
      @records.restore
      format.json { 
        render json: @records
      }
    end
  end

  def delete_multiple
    respond_to do |format|    
      @records = User.where(:id.in => params[:ids])      
      @records.trash
      format.json { 
        render json: @records
      }
    end
  end
end
