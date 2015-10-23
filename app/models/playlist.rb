class Playlist < ActiveRecord::Base
  # validates :spotify_playlist_id :user_id :name, presence: true
  belongs_to :user
  has_many :playlist_tracks
  has_many :tracks, through: :playlist_tracks

  def has_dup
    self.playlist_tracks.each do |playlist_track|
      if playlist_track.copies > 0
        return true
      end
    end
    false
  end
end
