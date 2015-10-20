class UsersController < ApplicationController
  # before_action :prevent_login_signup

  def index
    @user = user
  end

  def spotify
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    hashToken = spotify_user.to_hash["credentials"]["token"]
    hashID = spotify_user.to_hash["id"]
    if hashID.present? && hashToken.present?
      found_user = User.where(spotify_user_id:hashID).first
      if found_user
        session[:user_id] = found_user["id"]
        redirect_to users_path
      else
        user = User.create( spotify_user_id:hashID, spotify_auth_token:hashToken )
        if user.save
          session[:user_id] = user.id
          redirect_to users_path
        else
          redirect_to users_path
        end
      end
    end
  end

  def logout
    res = Typhoeus.get("https://www.spotify.com/logout")
    sessions[:user_id] = nil
    redirect_to :root
  end

private
def user
  @user ||=current_user
end

end
