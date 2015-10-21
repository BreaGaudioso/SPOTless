class SessionsController < ApplicationController
  def login
  end

  def logout
    res = Typhoeus.get("https://www.spotify.com/logout")
    session[:user_id] = nil
    flash[:sucess] = 'Singed Out'
    redirect_to :root
  end

end
