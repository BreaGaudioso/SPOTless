class PlaylistsController < ApplicationController
  def show
    binding.pry
    @playlist = playlist

  end

private
  def user
    @user ||=current_user
  end

  def playlist
    @playlist ||= Playlist.find(params[:id])
  end

end
