class TracksController < ApplicationController
require 'fuzzystringmatch'
require 'rspotify/oauth'
require 'rspotify'

  def show
    @user = current_user
    @matches = []
    searchstring = track.name
    tracks = Track.all
      jarow = FuzzyStringMatch::JaroWinkler.create( :native )
    tracks.each do |track|
      match = jarow.getDistance( searchstring, track.name)
      Fuzzy.where(track_id:@track.id, match:match, match_id:track.id).first_or_create
    end
    matchArray = track.fuzzies.where("match > .65")
    matchArray.sort { |a,b| a.match <=> b.match}
    matchIDArray = matchArray.pluck(:match_id).map(&:to_i)
    matchIDArray.each do |id|
      found_track = Track.find(id)
      @matches.push found_track if found_track.id != track.id
    end
    @track = track
  end

  def destroy
    areplaylist = Playlist.find(params['id'])
    p_id = Playlist.find(params['id']).spotify_playlist_id
    t_id = params['format']
    u_id = current_user.spotify_user_id
    s_id = areplaylist.snap_shot_id
    playlist = RSpotify::Playlist.find(u_id, p_id)
    positionsArray = areplaylist.playlist_tracks.where(track_id:t_id)
    positions = positionsArray.pluck(:positions).map(&:to_i)
    playlist.remove_tracks!(positions, snapshot_id:s_id)
    session[:spotify_user].remove_tracks!(positions, snapshot_id:s_id)
    redirect_to user_path(@areplaylist.user.id)
  end


private
  def track
    @track ||= Track.find(params[:id])
  end
end
