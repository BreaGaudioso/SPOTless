class AddCountToPlaylistTracks < ActiveRecord::Migration
  def change
    add_column :playlist_tracks, :count, :integer
    add_column :playlist_tracks, :positions, :string
  end
end
