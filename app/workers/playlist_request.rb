class PlaylistRequest
  include Sidekiq::Worker

  def perform(playlist_id, user_id, r_playlist_id, r_playlist_name, r_playlist_snapshot_id)
    #find or creates playlist
    found_playlist = Playlist.where(spotify_playlist_id:r_playlist_id, name:r_playlist_name, snap_shot_id:r_playlist_snapshot_id).first_or_create
    found_user = User.find user_id
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
    redirect_to user_path(found_user)
  end
end
