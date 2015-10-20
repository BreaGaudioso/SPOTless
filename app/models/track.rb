class Track < ActiveRecord::Base
  # validates :spotify_track_id :album_id :name, presence: true
  belongs_to :album
  has_many :artist_tracks
  has_many :artists, through: :artist_tracks
end
