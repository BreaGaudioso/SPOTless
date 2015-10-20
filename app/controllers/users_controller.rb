class UsersController < ApplicationController
  # before_action :prevent_login_signup

  def index
    @user = user
  end

  def spotify
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    data = spotify_user.playlists
    data.each do |playlist|
      puts playlist.id
    end
    # test2 = RSpotify::Playlist.find('donb91','10rjQcqX5eAW52R17NNYF0')
    binding.pry
    hashToken = spotify_user.to_hash["credentials"]["token"]
    puts spotify_user.to_hash
    hashID = spotify_user.to_hash["id"]
    if hashID.present? && hashToken.present?
      found_user = User.where(spotify_user_id:hashID).first
      if found_user
        session[:user_id] = found_user["id"]
        # get_spotify_data(found_user["id"])
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
    session[:user_id] = nil
    redirect_to :root
  end

  private
  def user
    @user ||=current_user
  end

  def get_spotify_data(user_id)
    user = User.find user_id

    request = Typhoeus::Request.new(
      "https://api.spotify.com/v1/users/#{user.spotify_user_id}/playlists",
      method: :get,
      params: { Authorization: "Bearer #{user.spotify_auth_token}" })
    data = request.run
    binding.pry
  end

end

