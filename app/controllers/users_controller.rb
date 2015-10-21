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
            PlaylistTrack.where(playlist_id: found_playlist.id).destroy_all
            found_user.playlists << found_playlist
            tracks = RSpotify::Playlist.find(found_user[:spotify_user_id], playlist.id)
            if tracks.total != 0
              counter_index = 0
              tracks.tracks_cache.each do |track|
                found_track = found_playlist.tracks.where(name:track.name, spotify_track_id:track.id).first
                if found_track
                  playlist_tracks = PlaylistTrack.where(track_id:found_track.id,playlist_id:found_playlist.id).last
                  PlaylistTrack.create(track_id:found_track.id,playlist_id:found_playlist.id,positions:counter_index,copies:playlist_tracks.copies + 1)
                else
                  found_track = found_playlist.tracks.create(name:track.name, spotify_track_id:track.id)
                  playlist_tracks = PlaylistTrack.where(track_id:found_track.id,playlist_id:found_playlist.id).first
                  PlaylistTrack.update(playlist_tracks.id, {copies:0, positions:"#{counter_index}"})
                end
                if track.album.images.size == 0
                  image = ""
                else
                  image = track.album.images[0]['url']
                end
                  new_album = Album.where(name:track.album.name, spotify_album_id:track.album.id, image_url:image).first_or_create
                  new_album.tracks << found_track
                  track.artists.each do |artist|
                  new_artist = found_track.artists.where(name:artist.name, spotify_artist_id:artist.id).first_or_create
                end
                counter_index += 1
              end
            end
          end
        end
        session[:user_id] = user.id
        flash[:sucess] = 'Signed In'
        redirect_to users_path
      end
    end
  end



  private
  def user
    @user ||=current_user
  end




end
