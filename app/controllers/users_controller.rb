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
    found_user.update_attributes(spotify_auth_token:request.env['omniauth.auth'].credentials.token)
    offset = 0
    spotifty_user_playlist = get_users_playlist(offset);
    while spotifty_user_playlist['total'] >= 50 + offset
      offset += 50
      spotifty_user_playlist['items'].concat get_users_playlist(offset)['items']
    end
    spotifty_user_playlist['items'].each do |playlist|
      offset = 0
      found_playlist = found_user.playlists.where(name:playlist['name'],spotify_playlist_id:playlist['id'],snap_shot_id:playlist['snapshot_id']).first_or_create
      spotifty_playlist_tracks = get_playlist_tracks(offset, playlist['id'])
      while spotifty_playlist_tracks['tracks']['total'] >= 100 + offset
        offset += 100
        spotifty_playlist_tracks.concat get_playlist_tracks(offset, playlist['id'])
      end
      spotifty_playlist_tracks['tracks']['items'].each do |track|
        found_track = found_playlist.tracks.where(name:track['track']['name'],spotify_track_id:track['track']['id']).first_or_create
        track['track']['artists'].each do |artist|
          found_artist = Artist.where(name:artist['name'], spotify_artist_id:artist['id']).first_or_create
          found_track.artists << found_artist unless found_track.artists.where(id:found_artist.id).first
          found_album = Album.where(name:track['track']['album']['name'], spotify_album_id:track['track']['album']['id']).first_or_create
          found_album.tracks << found_track unless found_album.tracks.where(id:found_track.id).first
          image = ''
          image = track['track']['album']['images'][0]['url'] if track['track']['album']['images'][0]['url']
          found_album.update_attributes(image_url: image)
          found_artist.albums << found_album unless found_artist.albums.where(id:found_album.id).first
        end
      end
    end

    # hashToken = spotify_user.to_hash["credentials"]["token"]
    # hashID = spotify_user.to_hash["id"]
    # #makes sure we have a vaild user back from spotify
    # if hashID.present? && hashToken.present?
    #   #finds or creates a user by spotify id
    #   found_user = User.where(spotify_user_id:hashID, spotify_user_id:spotify_user.id).first_or_create
    #   found_user.update_attributes(spotify_auth_token:hashToken)
    #   if found_user
    #     #logs user in
    #     session[:user_id] = found_user["id"]
    #     user_playlists.each do |playlist|
    #       #makes sure the user is the owner of playlist
    #       if spotify_user.id == playlist.owner.id
    #         #find or creates playlist
    #         found_playlist = Playlist.where(spotify_playlist_id:playlist.id, name:playlist.name, snap_shot_id:playlist.snapshot_id).first_or_create
    #         #cleans connections
    #         PlaylistTrack.where(playlist_id: found_playlist.id).destroy_all
    #         #add playlist to user
    #         found_user.playlists << found_playlist
    #         #gets playlist info from Spotify
    #         r_playlist = RSpotify::Playlist.find(found_user[:spotify_user_id], playlist.id)
    #         # makes sure playlist isn't empty
    #         if r_playlist.total != 0
    #           counter_index = 0
    #           #runs for each song in the playlist
    #           r_playlist.tracks.each do |track|
    #             #checks to see if the song is already on the playlist
    #             found_track = found_playlist.tracks.where(spotify_track_id:track.id).first
    #             #if track is on the play list update copies
    #             if found_track
    #               playlist_tracks = PlaylistTrack.where(track_id:found_track.id,playlist_id:found_playlist.id).last
    #               PlaylistTrack.create(track_id:found_track.id,playlist_id:found_playlist.id,positions:counter_index,copies:playlist_tracks.copies + 1)
    #             else
    #               #check if track is in the database
    #               found_track = Track.where(spotify_track_id:track.id).first
    #               #if track is in the database add the track to playlist
    #               if found_track
    #                 found_playlist.tracks << found_track
    #               else
    #                 #creates a new track on the database and addd it to the playlist
    #                 found_track = found_playlist.tracks.create(name:track.name, spotify_track_id:track.id)
    #               end
    #               #add sets copy and positions on playlistTrack
    #               playlist_tracks = PlaylistTrack.where(track_id:found_track.id,playlist_id:found_playlist.id).first
    #               PlaylistTrack.update(playlist_tracks.id, {copies:0, positions:"#{counter_index}"})
    #             end
    #             # makes sure there is a image
    #             if track.album.images.size == 0
    #               image = ""
    #             else
    #               image = track.album.images[0]['url']
    #             end
    #             #find or create new album and adds track to album
    #             new_album = Album.where(name:track.album.name, spotify_album_id:track.album.id, image_url:image).first_or_create
    #             track_present = new_album.tracks.where(id:found_track.id).first
    #             if !track_present
    #               new_album.tracks << found_track
    #               track.artists.each do |artist|
    #                 found_track.artists.where(name:artist.name, spotify_artist_id:artist.id).first_or_create
    #               end
    #             end
    #             counter_index += 1
    #           end
    #         end
    #
    #       end
    #     end
    #   end
    # end
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
    req =  Typhoeus::Request.new("https://api.spotify.com/v1/users/#{request.env['omniauth.auth'].info.id}/playlists/#{playlist_id}",
      method: :get,
      headers: {
        limit: 100,
        Accept: "application/json",
        Authorization: "Bearer #{request.env['omniauth.auth'].credentials.token}"
      })
      res = req.run
      JSON.parse(res.options[:response_body])
  end
end
