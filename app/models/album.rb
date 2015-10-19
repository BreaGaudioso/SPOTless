class Album < ActiveRecord::Base
  validates :spotify_album_id :name, presence: true
  has_many :tracks
  has_many :album_artists
  has_many :artists, through: :album_artists  
end
