class Artist < ActiveRecord::Base
  validates :spotify_aritst_id :name, presence: true
  has_many :album_artists
  has_many :albums, through: :album_artists
  has_many :artist_tracks
  has_many :tracks, through: :artist_tracks
end
