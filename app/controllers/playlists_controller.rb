class PlaylistsController < ApplicationController
  def show
    @areplaylist = areplaylist
    @user = user
  end

  def destroy
    p_id = areplaylist.spotify_playlist_id
    u_id = current_user.spotify_user_id
    s_id = areplaylist.snap_shot_id
    playlist = RSpotify::Playlist.find(u_id, p_id)
    positionsArray = areplaylist.playlist_tracks.where("copies > 0")
    positions = positionsArray.pluck(:positions).map(&:to_i)
    positionsArray.each do |song|
      song.destroy
    end
    playlist.remove_tracks!(positions, snapshot_id:s_id)
    redirect_to user_path(@areplaylist.user.id)
  end

private
  def user
    @user ||=current_user
  end

  def areplaylist
    @areplaylist ||= Playlist.find(params[:id])
  end
end
