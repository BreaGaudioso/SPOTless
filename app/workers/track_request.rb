class TrackRequest
  include Sidekiq::Worker

  def perform(playlist_id, user_id)
    found_playlist = Playlist.find playlist_id
    found_user = User.find user_id
    offset = 0
    counter_index = 0
    spotifty_playlist_tracks = get_playlist_tracks(offset,found_user.spotify_user_id, found_user.spotify_auth_token, found_playlist.spotify_playlist_id)
    while spotifty_playlist_tracks['total'] >= 100 + offset
      offset += 100
      spotifty_playlist_tracks['items'] = spotifty_playlist_tracks['items'].concat get_playlist_tracks(offset,found_user.spotify_user_id, found_user.spotify_auth_token, found_playlist.spotify_playlist_id)['items']
    end
    if spotifty_playlist_tracks['total'] != 0
      spotifty_playlist_tracks['items'].each do |track|
        found_track = found_playlist.tracks.where(name:track['track']['name'],spotify_track_id:track['track']['id']).first
        if found_track
          playlist_tracks = PlaylistTrack.where(track_id:found_track.id,playlist_id:playlist_id).last
          PlaylistTrack.create(track_id:found_track.id, playlist_id:playlist_id, positions:playlist_tracks.count, copies:playlist_tracks.copies + 1 )
        else
          found_track = Track.where(spotify_track_id:track['track']['id']).first
          if found_track
            found_playlist.tracks << found_track
          else
            found_track = found_playlist.tracks.create(name:track['track']['name'], spotify_track_id:track['track']['id'])
          end
          playlist_tracks = PlaylistTrack.where(track_id:found_track.id,playlist_id:found_playlist.id).first
          PlaylistTrack.update(playlist_tracks.id, {copies:0, positions:playlist_tracks.copies})
        end
        track['track']['artists'].each do |artist|
          found_artist = Artist.where(name:artist['name'], spotify_artist_id:artist['id']).first_or_create
          found_track.artists << found_artist unless found_track.artists.where(id:found_artist.id).first
          found_album = Album.where(name:track['track']['album']['name'], spotify_album_id:track['track']['album']['id']).first_or_create
          found_album.tracks << found_track unless found_album.tracks.where(id:found_track.id).first
          image = ''
          image = track['track']['album']['images'][0]['url'] if track['track']['album']['images'].size > 0
          found_album.update_attributes(image_url: image)
          found_artist.albums << found_album unless found_artist.albums.where(id:found_album.id).first
        end
        counter_index += 1
      end
    end
  end

  def get_playlist_tracks(offset, user_id, token, playlist_id)
    req = Typhoeus::Request.new("https://api.spotify.com/v1/users/#{user_id}/playlists/#{playlist_id}/tracks?offset=#{offset}&limt=100",
      method: :get,
      headers: {
        Accept: "application/json",
        Authorization: "Bearer #{token}"
      })
      res = req.run
      json_res = JSON.parse(res.options[:response_body])
  end
end
