class PlaylistsController < ApplicationController
  def show
    @playlist = playlist
    @user = user
  end

private
  def user
    @user ||=current_user
  end

  def playlist
    @playlist ||= Playlist.find(params[:id])
  end
end
