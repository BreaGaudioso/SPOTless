class SessionsController < ApplicationController
  def login
  end

  def logout
    res = Typhoeus.get("https://www.spotify.com/us/logout")
    session[:user_id] = nil
    flash[:sucess] = 'Signed Out'
    redirect_to :root
  end

end
