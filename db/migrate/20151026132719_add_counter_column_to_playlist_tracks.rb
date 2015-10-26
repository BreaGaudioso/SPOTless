class AddCounterColumnToPlaylistTracks < ActiveRecord::Migration
  def change
    add_column :playlist_tracks, :position_count, :integer
  end
end
