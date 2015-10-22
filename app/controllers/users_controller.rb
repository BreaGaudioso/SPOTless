class UsersController < ApplicationController
  # before_action :prevent_login_signup

  def index
    user
  end

  def show
    user
  end

  def spotify
    # get spotify account
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    user_playlists = spotify_user.playlists
    hashToken = spotify_user.to_hash["credentials"]["token"]
    hashID = spotify_user.to_hash["id"]
    #makes sure we have a vaild user back from spotify
    if hashID.present? && hashToken.present?
      #finds or creates a user by spotify id
      found_user = User.where(spotify_user_id:hashID, spotify_user_id:spotify_user.id).first_or_create
      found_user.update_attributes(spotify_auth_token:hashToken)
      if found_user
        #logs user in
        session[:user_id] = found_user["id"]
        user_playlists.each do |playlist|
          #makes sure the user is the owner of playlist
          if spotify_user.id == playlist.owner.id
            PlaylistRequest.perform_async(playlist.id, found_user.id, playlist.id, playlist.name, playlist.snapshot_id);
          end
        end
        session[:user_id] = found_user.id
        flash[:sucess] = 'Signed In'
        redirect_to user_path(found_user)
      end
    end
  end

  private
  def user
    @user ||=current_user
  end




end
