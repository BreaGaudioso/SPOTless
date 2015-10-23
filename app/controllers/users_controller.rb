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
      if playlist['owner']['id'] == found_user.spotify_user_id
        spotifty_playlist_tracks = get_playlist_tracks(offset, playlist['id'])
        while spotifty_playlist_tracks['total'] >= 100 + offset
          offset += 100
          spotifty_playlist_tracks['items'] = spotifty_playlist_tracks['items'].concat get_playlist_tracks(offset, playlist['id'])['items']
        end
        spotifty_playlist_tracks['items'].each do |track|
          found_track = found_playlist.tracks.where(name:track['track']['name'],spotify_track_id:track['track']['id']).first_or_create
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
        end
      end
    end
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
