class UsersController < ApplicationController
  # before_action :prevent_login_signup

  def index
    user
  end

  def show
    user
    @user = user
  end

  def destroy
    areplaylists.each do |areplaylist|
      positions = []
      positions.push(areplaylist.playlist_tracks.where("copies > 0"))
      if positions.flatten.length > 0
        p_id = areplaylist.spotify_playlist_id
        u_id = current_user.spotify_user_id
        s_id = areplaylist.snap_shot_id
        playlist = RSpotify::Playlist.find(u_id, p_id)
        positions.each do |song|
          song[0].destroy
          playlist.remove_tracks!(song.pluck(:positions).map(&:to_i), snapshot_id:s_id)
        end
      end
    end
    redirect_to user_path(current_user)
  end

  def spotify
    session[:spotify_user] = RSpotify::User.new(request.env['omniauth.auth'])
    found_user = User.where(spotify_user_id:request.env['omniauth.auth'].info.id).first_or_create
    if request.env['omniauth.auth'].info.display_name.present?
      userName = request.env['omniauth.auth'].info.display_name
    else
      userName = request.env['omniauth.auth'].info.id
    end
    found_user.update_attributes(spotify_auth_token:request.env['omniauth.auth'].credentials.token, username:userName)
    PlaylistRequest.perform_async(found_user.id)
    session[:user_id] = found_user.id
    flash[:sucsess] = 'Signed In'
    redirect_to user_path(found_user)
  end

private
  def user
    @user ||=current_user
  end

  def areplaylists
    @areplaylists ||= Playlist.where(user_id:current_user.id)
  end
end
