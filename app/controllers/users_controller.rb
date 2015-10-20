class UsersController < ApplicationController
  # before_action :prevent_login_signup

  def index
    @user = user
  end

  def spotify
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    user_playlists = spotify_user.playlists

    hashToken = spotify_user.to_hash["credentials"]["token"]
    hashID = spotify_user.to_hash["id"]
    if hashID.present? && hashToken.present?
      found_user = User.where(spotify_user_id:hashID, spotify_user_id:spotify_user.id).first_or_create
      found_user.update_attributes(spotify_auth_token:hashToken)
      if found_user
        session[:user_id] = found_user["id"]
        user_playlists.each do |playlist|
          if spotify_user.id == playlist.owner.id
            found_playlist = Playlist.where(spotify_playlist_id:playlist.id, name:playlist.name).first_or_create
            puts playlist.name
            puts playlist.id
            puts spotify_user.id
            tracks = RSpotify::Playlist.find(found_user[:spotify_user_id], playlist.id)
            if tracks.total != 0
              tracks.tracks_cache.each do |track|
                new_track = found_playlist.tracks.where(name:track.name, spotify_track_id:track.id).first_or_create
                if track.album.images.size == 0
                  image = ""
                else
                  image = track.album.images[0]['url']
                end
                new_album = Album.where(name:track.album.name, spotify_album_id:track.album.id, image_url:image).first_or_create
                new_album.tracks << new_track
                track.artists.each do |artist|
                  new_artist = new_track.artists.where(name:artist.name, spotify_artist_id:artist.id).first_or_create
                end
              end
            end
          end
        end
        session[:user_id] = user.id
        redirect_to users_path
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

    data = spotify_user.playlists
    data.each do |playlist|
      puts playlist.id
    end
  end

end
