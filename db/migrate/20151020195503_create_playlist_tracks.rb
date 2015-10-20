class CreatePlaylistTracks < ActiveRecord::Migration
  def change
    create_table :playlist_tracks do |t|
      t.integer :track_id
      t.integer :playlist_id
      t.timestamps null: false
    end
  end
end
