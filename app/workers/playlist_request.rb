class PlaylistRequest
  include Sidekiq::Worker

  def perform(user_id)
    found_user = User.find user_id
    offset = 0
    spotifty_user_playlist = get_users_playlist(offset, found_user.spotify_user_id, found_user.spotify_auth_token);

    while spotifty_user_playlist['total'] >= 50 + offset
      offset += 50
      spotifty_user_playlist['items'].concat get_users_playlist(offset, found_user.spotify_user_id, found_user.spotify_auth_token)['items']
    end

    spotifty_user_playlist['items'].each do |playlist|
      offset = 0
      if playlist['owner']['id'] == found_user.spotify_user_id
        found_playlist = found_user.playlists.where(name:playlist['name'],spotify_playlist_id:playlist['id'],snap_shot_id:playlist['snapshot_id']).first_or_create
        PlaylistTrack.where(playlist_id: found_playlist.id).destroy_all
        TrackRequest.perform_async(found_playlist.id, found_user.id)
      end
    end
  end

  def get_users_playlist(offset, user_id, token)
    req = Typhoeus::Request.new("https://api.spotify.com/v1/users/#{user_id}/playlists/?offset=#{offset}&limit=50",
      method: :get,
      headers: {
        Accept: "application/json",
        Authorization: "Bearer #{token}"
      })
      res = req.run
      JSON.parse(res.options[:response_body])
  end


end
