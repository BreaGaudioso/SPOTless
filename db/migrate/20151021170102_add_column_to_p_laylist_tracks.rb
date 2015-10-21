class AddColumnToPLaylistTracks < ActiveRecord::Migration
  def change
    remove_column :playlist_tracks, :count
    add_column :playlist_tracks, :copies, :integer
  end
end
