class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  def loading

  end

  def current_user
    return unless session[:user_id]
    @current_user ||=User.find session[:user_id]
  end
    helper_method :current_user

  def prevent_login_signup
    if session[:user_id]
      redirect_to :back
      flash[:notice] = "You Are Still to Logged In"
    end

  end
end
