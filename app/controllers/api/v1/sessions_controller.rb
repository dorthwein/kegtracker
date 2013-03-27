class Api::V1::SessionsController < Devise::SessionsController  
  def create
    respond_to do |format|
#      format.html {
#        super
#      }
      format.json {
        build_resource
        user = User.find_for_database_authentication(:email => params[:user][:email])
        return invalid_login_attempt unless resource

        if user.valid_password?(params[:user][:password])
          render :json => { :auth_token => user.authentication_token, :user_id => user._id }, success: true, status: :created
        else
          invalid_login_attempt
        end
      }
    end
  end

  def destroy
    respond_to do |format|
#      format.html {
#        super
#      }
      format.json {
        user = User.where(:authentication_token => params[:auth_token]).first
        print params.to_json + 'fuck'
        if user         
          user.reset_authentication_token!
          render :json => { :message => 'Session deleted.' }, :success => true, :status => 204
        else
          render :json => { :message => 'Invalid token.' }, :status => 404
        end
      }
    end
  end

  protected
  def invalid_login_attempt
    warden.custom_failure!
    render json: { success: false, message: 'Error with your login or password' }, status: 401
  end
end
