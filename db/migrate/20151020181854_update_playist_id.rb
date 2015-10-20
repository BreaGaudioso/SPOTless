class UpdatePlayistId < ActiveRecord::Migration
  def change
    remove_column :playlists, :spotify_playlist_id
    add_column :playlists, :spotify_playlist_id, :string
  end
end
