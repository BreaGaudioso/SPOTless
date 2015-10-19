class User < ActiveRecord::Base
  validates :spotify_user_id :spotify_auth_token, presence: true
end
