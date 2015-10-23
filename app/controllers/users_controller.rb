class UsersController < ApplicationController
  # before_action :prevent_login_signup

  def index
    user
  end

  def show
    user
  end



  def spotify
    found_user = User.where(spotify_user_id:request.env['omniauth.auth'].info.id).first_or_create
    if request.env['omniauth.auth'].info.display_name.present?
      userName = request.env['omniauth.auth'].info.display_name
    else
      userName = request.env['omniauth.auth'].info.id
    end
    found_user.update_attributes(spotify_auth_token:request.env['omniauth.auth'].credentials.token, username:userName)
    PlaylistRequest.perform_async(found_user.id)
    session[:user_id] = found_user.id
    flash[:sucess] = 'Signed In'
    redirect_to user_path(found_user)
  end

  private
  def user
    @user ||=current_user
  end

  def get_users_playlist(offset)
    req =  Typhoeus::Request.new("https://api.spotify.com/v1/users/#{request.env['omniauth.auth'].info.id}/playlists/?offset=#{offset}&limit=50",
      method: :get,
      headers: {
        Accept: "application/json",
        Authorization: "Bearer #{request.env['omniauth.auth'].credentials.token}"
      })
      res = req.run
      JSON.parse(res.options[:response_body])
  end

  def get_playlist_tracks(offset, playlist_id)
    req =  Typhoeus::Request.new("https://api.spotify.com/v1/users/#{request.env['omniauth.auth'].info.id}/playlists/#{playlist_id}/tracks?offset=#{offset}&limt=100",
      method: :get,
      headers: {
        Accept: "application/json",
        Authorization: "Bearer #{request.env['omniauth.auth'].credentials.token}"
      })
      res = req.run
      json_res = JSON.parse(res.options[:response_body])
  end
end
