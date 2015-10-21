class AddColumnSnapshotIdToPlaylists < ActiveRecord::Migration
    add_column :playlists, :snap_shot_id, :string
  def change
  end
end
