require 'rspotify'

class PlaylistRequest
  include Sidekiq::Worker

  def perform(playlist_id, user_id, r_playlist_id, r_playlist_name, r_playlist_snapshot_id)
  end
end
