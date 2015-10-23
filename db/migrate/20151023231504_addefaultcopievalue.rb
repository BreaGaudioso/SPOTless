class Addefaultcopievalue < ActiveRecord::Migration
  def change
    change_column :playlist_tracks, :copies, :integer ,default: 0
  end
end
