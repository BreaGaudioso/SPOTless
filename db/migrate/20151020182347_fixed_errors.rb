class FixedErrors < ActiveRecord::Migration
  def change
    remove_column :tracks, :spotify_track_id
    add_column :tracks, :spotify_track_id, :string
    remove_column :albums, :spotify_album_id
    add_column :albums, :spotify_album_id, :string
    remove_column :artists, :spotify_artist_id
    add_column :artists, :spotify_artist_id, :string
  end
end
