class UsersController < ApplicationController
  # before_action :prevent_login_signup

  def index
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
            #find or creates playlist
            found_playlist = Playlist.where(spotify_playlist_id:playlist.id, name:playlist.name, snap_shot_id:playlist.snapshot_id).first_or_create
            #cleans connections
            PlaylistTrack.where(playlist_id: found_playlist.id).destroy_all
            #add playlist to user
            found_user.playlists << found_playlist
            #gets playlist info from Spotify
            r_playlist = RSpotify::Playlist.find(found_user[:spotify_user_id], playlist.id)
            #makes sure playlist isn't empty
            if r_playlist.total != 0
              counter_index = 0
              #runs for each song in the playlist
              r_playlist.tracks_cache.each do |track|
                #checks to see if the song is already on the playlist
                found_track = found_playlist.tracks.where(spotify_track_id:track.id).first
                #if track is on the play list update copies
                if found_track
                  playlist_tracks = PlaylistTrack.where(track_id:found_track.id,playlist_id:found_playlist.id).last
                  PlaylistTrack.create(track_id:found_track.id,playlist_id:found_playlist.id,positions:counter_index,copies:playlist_tracks.copies + 1)
                else
                  #check if track is in the database
                  found_track = Track.where(spotify_track_id:track.id).first
                  #if track is in the database add the track to playlist
                  if found_track
                    found_playlist.tracks << found_track
                  else
                    #creates a new track on the database and addd it to the playlist
                    found_track = found_playlist.tracks.create(name:track.name, spotify_track_id:track.id)
                  end
                  #add sets copy and positions on playlistTrack
                  playlist_tracks = PlaylistTrack.where(track_id:found_track.id,playlist_id:found_playlist.id).first
                  PlaylistTrack.update(playlist_tracks.id, {copies:0, positions:"#{counter_index}"})
                end
                # makes sure there is a image
                if track.album.images.size == 0
                  image = ""
                else
                  image = track.album.images[0]['url']
                end
                #find or create new album and adds track to album
                new_album = Album.where(name:track.album.name, spotify_album_id:track.album.id, image_url:image).first_or_create
                track_present = new_album.tracks.where(id:found_track.id).first
                if !track_present
                  new_album.tracks << found_track
                  track.artists.each do |artist|
                    found_track.artists.where(name:artist.name, spotify_artist_id:artist.id).first_or_create
                  end
                end
                counter_index += 1
              end
            end
          end
        end
        session[:user_id] = found_user.id
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
