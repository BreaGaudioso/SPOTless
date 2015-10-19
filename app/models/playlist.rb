class Playlist < ActiveRecord::Base
  validates :spotify_playlist_id :user_id :name, presence: true
  belongs_to :user
end
